require "rails_helper"

describe "/api/v7/relations", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=7" }
  end

  context "index" do
    context "JSON" do
      let!(:relations) { FactoryGirl.create(:relation) }
      let(:uri) { "/api/relations" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["relations"].length).to eq(1)

        item = response["relations"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["subj_id"]).to be_present
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["relations"].length).to eq(1)

        item = response["relations"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["subj_id"]).to be_present
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end

    context "show subj_id" do
      let(:work) { FactoryGirl.create(:work, :with_events) }
      let!(:relation) { FactoryGirl.create(:relation, work: work) }
      let(:uri) { "/api/works/#{work.pid}/relations" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)

        item = response["relations"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(1)

        item = response["relations"].first
        expect(item["source_id"]).to eq("citeulike")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end
  end
end
