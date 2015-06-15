require "rails_helper"

describe "/api/v6/groups", :type => :api do
  let!(:source) { FactoryGirl.create(:source) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version 6" }
  end

  context "index" do
    let(:uri) { "/api/groups" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      data = response["groups"]
      expect(data.length).to eq(1)

      item = data.first
      expect(item["id"]).to eq("saved")
      expect(item["title"]).to eq("Saved")
      expect(item["sources"]).to eq(["citeulike"])
    end
  end

  context "show" do
    let(:uri) { "/api/groups/saved" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      item = response["group"]
      expect(item["id"]).to eq("saved")
      expect(item["title"]).to eq("Saved")
      expect(item["sources"]).to eq(["citeulike"])
    end
  end
end
