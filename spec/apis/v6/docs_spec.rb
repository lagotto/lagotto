require "rails_helper"

describe "/api/v6/docs", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version 6" }
  end

  context "index" do
    let(:uri) { "/api/docs" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      data = response["docs"]
      expect(data.length).to eq(57)

      item = data.first
      expect(item["id"]).to eq ("ads")
      expect(item["title"]).to eq ("ADS")
    end
  end

  context "show" do
    let(:uri) { "/api/docs/alerts" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      item = response["doc"]
      expect(item["id"]).to eq ("alerts")
      expect(item["title"]).to eq ("Alerts")
      expect(item["layout"]).to eq ("card_list")
      expect(item["content"][0]["subtitle"]).to eq ("Setup")
    end
  end
end
