require "rails_helper"

describe "/api/v7/work_types", :type => :api do
  let!(:work_type) { FactoryGirl.create(:work_type) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7" }
  end

  context "index" do
    let(:uri) { "/api/work_types" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      data = response["work_types"]
      expect(data.length).to eq(1)

      item = data.first
      expect(item["id"]).to eq("article-journal")
      expect(item["title"]).to eq("Journal Article")
      expect(item["container"]).to eq("Journal")
    end
  end

  context "show" do
    let(:uri) { "/api/work_types/article-journal" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      item = response["work_type"]
      expect(item["id"]).to eq("article-journal")
      expect(item["title"]).to eq("Journal Article")
      expect(item["container"]).to eq("Journal")
    end
  end
end
