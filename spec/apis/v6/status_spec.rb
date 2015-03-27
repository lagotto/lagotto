require "rails_helper"

describe "/api/v6/status", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    let!(:works) { FactoryGirl.create_list(:work_published_today, 5) }
    let!(:status) { FactoryGirl.create(:status) }
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v6/status" }

    context "get response" do
      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        item = response["status"].first
        expect(item["updateDate"]).not_to eq("1970-01-01T00:00:00Z")
        expect(item["worksCount"]).to eq(10)
        expect(item["version"]).to eq(Lagotto::VERSION)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        item = response["status"].first
        expect(item["updateDate"]).not_to eq("1970-01-01T00:00:00Z")
        expect(item["worksCount"]).to eq(10)
        expect(item["version"]).to eq(Lagotto::VERSION)
      end
    end
  end
end
