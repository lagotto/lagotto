require "rails_helper"

describe "/api/v6/api_requests", :type => :api do
  let(:user) { FactoryGirl.create(:admin_user) }
  let!(:api_requests) { FactoryGirl.create_list(:api_request, 10) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "index" do
    let(:uri) { "/api/api_requests" }

    it "JSON" do
      get uri, nil, headers
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      data = response["api_requests"]
      expect(data.length).to eq(10)

      item = data.first
      expect(item["db_duration"]).to eq(100.0)
      expect(item["view_duration"]).to eq(700.0)
    end
  end
end
