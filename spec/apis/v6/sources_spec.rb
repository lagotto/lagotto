require "rails_helper"

describe "/api/v6/sources", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/sources" }

    context "get jobs" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 10)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(@source.name)
        expect(item["status"]["stale"]).to eq(10)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(@source.name)
        expect(item["status"]["stale"]).to eq(10)
      end
    end

    context "get responses" do
      let!(:source) { FactoryGirl.create(:source_with_api_responses) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(source.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(source.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end
    end

    context "get events" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 10)
      end

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["sources"]
        item = data.first
        expect(item["id"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end
    end
  end

  context "show" do
    context "get response" do
      let(:source) { FactoryGirl.create(:source_with_api_responses) }
      let!(:works) { FactoryGirl.create_list(:work_with_events, 5) }
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/sources/#{source.name}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["source"]
        expect(data["id"]).to eq(source.name)
        expect(data["work_count"]).to eq(5)
        expect(data["event_count"]).to eq(250)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["status"]["stale"]).to eq(5)
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["source"]
        expect(data["id"]).to eq(source.name)
        expect(data["work_count"]).to eq(5)
        expect(data["event_count"]).to eq(250)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["status"]["stale"]).to eq(5)
      end
    end
  end
end
