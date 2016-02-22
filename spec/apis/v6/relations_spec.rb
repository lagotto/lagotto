require "rails_helper"

describe "/api/v6/relations", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=6" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=6" }
  end

  context "index" do
    context "JSON" do
      let!(:relations) { FactoryGirl.create_list(:relation, 5) }
      let(:uri) { "/api/relations" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["relations"].length).to eq(5)

        item = response["relations"].first
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
        expect(response["relations"].length).to eq(5)

        item = response["relations"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["work_id"]).to be_present
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end

      it "can be sorted by works.created_at using the created_at query parameter" do
        get "#{uri}?sort=created_at", nil, headers
        response = JSON.parse(last_response.body)
        data = response["relations"]
        actual_work_dois = data.map{ |work| work["DOI"] }

        expected_work_dois = Relation.includes(:related_work)
          .order("works.created_at ASC")
          .map(&:related_work)
          .map(&:doi)

        expect(actual_work_dois).to eq(expected_work_dois)
      end
    end

    context "show work_id" do
      let(:work) { FactoryGirl.create(:work, :with_events) }
      let!(:relation) { FactoryGirl.create(:relation, work: work) }
      let(:uri) { "/api/works/#{work.pid}/relations" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)

        item = response["relations"].first
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

        item = response["relations"].first
        expect(item["source_id"]).to eq("crossref")
        expect(item["title"]).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(item["events"]).to eq({})
      end
    end
  end
end
