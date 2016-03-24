require "rails_helper"

describe "/api/v7/agents", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/agents" }

    context "get jobs" do
      let!(:agent) { FactoryGirl.create(:agent) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["agents"]
        item = data.first
        expect(item["id"]).to eq(agent.name)
        expect(item["state"]).to eq("waiting")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["agents"]
        item = data.first
        expect(item["id"]).to eq(agent.name)
        expect(item["state"]).to eq("waiting")
      end
    end

    context "get responses" do
      let!(:agent) { FactoryGirl.create(:agent_with_api_responses) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["agents"]
        item = data.first
        expect(item["id"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["agents"]
        item = data.first
        expect(item["id"]).to eq(agent.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end
    end
  end

  context "show" do
    context "get response" do
      let(:agent) { FactoryGirl.create(:agent_with_api_responses) }
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/agents/#{agent.name}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => headers
        #expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["agent"]
        expect(data["id"]).to eq(agent.name)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["state"]).to eq("waiting")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["agent"]
        expect(data["id"]).to eq(agent.name)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["state"]).to eq("waiting")
      end
    end
  end
end
