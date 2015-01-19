require "rails_helper"

describe "/api/v5/status", :type => :api do
  subject { FactoryGirl.create(:status) }

  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/status?api_key=#{user.authentication_token}" }

    context "get response" do
      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => "application/json"
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        expect(item["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(item["works_count"]).to eq(5)
        expect(item["responses_count"]).to eq(5)
        expect(item["requests_count"]).to eq(5)
        expect(item["version"]).to eq(Rails.application.config.version)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        expect(item["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(item["works_count"]).to eq(5)
        expect(item["responses_count"]).to eq(6)
        expect(item["requests_count"]).to eq(1)
        expect(item["version"]).to eq(Rails.application.config.version)
      end
    end
  end
end
