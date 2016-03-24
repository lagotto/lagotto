require "rails_helper"

describe "/api/v7/relation_types", :type => :api do
  let!(:relation_type) { FactoryGirl.create(:relation_type) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7" }
  end

  context "index" do
    let(:uri) { "/api/relation_types" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      data = response["relation_types"]
      expect(data.length).to eq(1)

      item = data.first
      expect(item["id"]).to eq("is_cited_by")
      expect(item["title"]).to eq("Is cited by")
    end
  end

  context "show" do
    let(:uri) { "/api/relation_types/is_cited_by" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      item = response["relation_type"]
      expect(item["id"]).to eq("is_cited_by")
      expect(item["title"]).to eq("Is cited by")
    end
  end
end
