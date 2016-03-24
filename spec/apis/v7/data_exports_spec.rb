require "rails_helper"

describe "/api/v7/data_exports", :type => :api do
  let(:error) { { "meta"=> { "status"=>"error", "error"=>"You are not authorized to access this page." } } }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:uri) { "/api/data_exports" }

  describe "index" do
    context "as a regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }

      it "JSON - 401 authoriziation error" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "as a staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }

      it "JSON - 200 OK" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)
      end
    end

    context "as an admin user" do
      let(:user) { FactoryGirl.create(:user, role: "admin") }

      it "JSON - 200 OK" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)
      end
    end

    context "as an authenticated user" do
      let(:user) { FactoryGirl.create(:admin_user) }

      def expect_items(items)
        actual_item_order = items.map{ |export| export["state"] }
        expected_item_order = data_exports.sort_by(&:id).reverse.map(&:state)
        expect(actual_item_order).to eq(expected_item_order)

        item = items.find{ |i| i["state"] == "done" }
        expect(item["state"]).to eq(finished_data_export.state)
        expect(item["url"]).to eq(finished_data_export.url)
        expect(item["started_exporting_at"]).to_not be_nil
        expect(item["finished_exporting_at"]).to_not be_nil
        expect(item["data"]).to_not be_nil

        item = items.find{ |i| i["state"] == "failed" }
        expect(item["failed_at"]).to_not be_nil

        item = items.find{ |i| i["type"] == ZenodoDataExport.name }
        expect(item).to_not be_nil
      end

      context "JSON" do
        let!(:data_exports) { [failed_data_export, pending_data_export, started_data_export, finished_data_export, zenodo_data_export] }
        let!(:failed_data_export){ FactoryGirl.create(:data_export, failed_at: Time.zone.now) }
        let!(:pending_data_export){ FactoryGirl.create(:data_export, started_exporting_at:nil, finished_exporting_at: nil) }
        let!(:started_data_export){ FactoryGirl.create(:data_export, started_exporting_at:Time.zone.now, finished_exporting_at:nil) }
        let!(:finished_data_export){ FactoryGirl.create(:data_export, started_exporting_at:Time.zone.now, finished_exporting_at:Time.zone.now) }
        let!(:zenodo_data_export){ FactoryGirl.create(:zenodo_data_export) }

        it "JSON" do
          get uri, nil, headers
          expect(last_response.status).to eq(200)

          response = JSON.parse(last_response.body)
          expect(response["data_exports"].length).to eq(data_exports.length)

          expect_items response["data_exports"]
        end

        it "JSONP" do
          get "#{uri}?callback=_func", nil, jsonp_headers
          expect(last_response.status).to eql(200)

          # remove jsonp wrapper
          response = JSON.parse(last_response.body[6...-1])
          expect(response["data_exports"].length).to eq(data_exports.length)

          expect_items response["data_exports"]
        end
      end
    end
  end
end
