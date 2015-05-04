require "rails_helper"

describe "/api/v6/alerts", :type => :api do
  let(:error) { { "meta"=> { "status"=>"error", "error"=>"You are not authorized to access this page." } } }
  let(:user) { FactoryGirl.create(:admin_user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version 6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "index" do
    context "most recent alerts" do
      let(:uri) { "/api/alerts" }
      let!(:alert) { FactoryGirl.create_list(:alert, 10) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(10)
        item = data.first
        expect(item["level"]).to eq ("WARN")
        expect(item["message"]).to eq ("The request timed out.")
      end
    end

    context "only unresolved alerts" do
      let(:uri) { "/api/alerts?unresolved=1" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2, unresolved: false)
        FactoryGirl.create(:alert)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["unresolved"]).to be true
      end
    end

    context "with source" do
      let(:uri) { "/api/alerts?source_id=citeulike" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert_with_source)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["source"]).to eq ("citeulike")
      end
    end

    context "with class_name" do
      let(:uri) { "/api/alerts?class_name=nomethoderror" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with level ERROR" do
      let(:uri) { "/api/alerts?level=error" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, level: Alert::ERROR)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["level"]).to eq ("ERROR")
      end
    end

    context "with query" do
      let(:uri) { "/api/alerts?q=nomethod" }

      before(:each) do
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:alert, class_name: "NoMethodError")
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(1)
        alert = data.first
        expect(alert["class_name"]).to eq ("NoMethodError")
      end
    end

    context "with pagination" do
      let(:uri) { "/api/alerts?page=2" }

      before(:each) { FactoryGirl.create_list(:alert, 55) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(5)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, role: "staff") }
      let!(:alert) { FactoryGirl.create_list(:alert, 10) }
      let(:uri) { "/api/alerts" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["alerts"]
        expect(data.length).to eq(10)
        item = data.first
        expect(item["level"]).to eq ("WARN")
        expect(item["message"]).to eq ("The request timed out.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, role: "user") }
      let(:uri) { "/api/alerts" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end
  end
end
