require "rails_helper"

describe "/api/v5/status" do
  subject { Status.new }

  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/status?api_key=#{user.authentication_token}" }

    context "get response" do
      before(:each) do
        date = Date.today - 1.day
        FactoryGirl.create_list(:article_with_events, 5, year: date.year, month: date.month, day: date.day)
        FactoryGirl.create_list(:alert, 2)
        FactoryGirl.create(:delayed_job)
        FactoryGirl.create_list(:api_request, 4)
        FactoryGirl.create_list(:api_response, 6)
        body = File.read(fixture_path + 'releases.json')
        stub_request(:get, "https://api.github.com/repos/articlemetrics/lagotto/releases").to_return(body: body)
        subject.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => "application/json"
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(data["articles_count"]).to eq(5)
        expect(data["responses_count"]).to eq(6)
        expect(data["users_count"]).to eq(1)
        expect(data["version"]).to eq(Rails.application.config.version)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data["update_date"]).not_to eq("1970-01-01T00:00:00Z")
        expect(data["articles_count"]).to eq(5)
        expect(data["responses_count"]).to eq(6)
        expect(data["users_count"]).to eq(1)
        expect(data["version"]).to eq(Rails.application.config.version)
      end
    end
  end
end
