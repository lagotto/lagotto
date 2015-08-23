require "rails_helper"

describe "/api/v6/references", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6" }
  end

  context "index" do
    context "JSON" do
      let!(:relations) { FactoryGirl.create_list(:relation, 5) }
      let(:uri) { "/api/references" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["references"].length).to eq(5)

        item = response["references"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["work_id"]).to be_present
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["references"].length).to eq(5)

        item = response["references"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["work_id"]).to be_present
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end

    context "show work_id" do
      let(:work) { FactoryGirl.create(:work, :with_events) }
      let!(:relation) { FactoryGirl.create(:relation, work: work) }
      let(:uri) { "/api/works/#{work.pid}/references" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)

        item = response["references"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(1)

        item = response["references"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end
  end
end
