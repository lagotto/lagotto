require "rails_helper"

describe "/api/v6/references", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6" }
  end

  context "index" do
    context "JSON" do
      let!(:relationships) { FactoryGirl.create_list(:relationship, 5) }
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
      let(:work) { FactoryGirl.create(:work_with_events) }
      let!(:relationship) { FactoryGirl.create(:relationship, work: work) }
      let(:uri) { "/api/works/#{work.pid}/related_works" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)

        item = response["related_works"].first
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

        item = response["related_works"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end
  end
end
