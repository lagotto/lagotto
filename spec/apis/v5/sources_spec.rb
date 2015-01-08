require "rails_helper"

describe "/api/v5/sources", :type => :api do
  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/sources?api_key=#{user.authentication_token}" }

    context "get jobs" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 10)
        @source.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["status"]["stale"]).to eq(10)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["status"]["stale"]).to eq(10)
      end
    end

    context "get responses" do
      before(:each) do
        @source = FactoryGirl.create(:source_with_api_responses)
        @source.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["responses"]["count"]).to eq(5)
        expect(item["responses"]["average"]).to eq(200)
      end
    end

    context "get events" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @works = FactoryGirl.create_list(:work_with_events, 10)
        @source.update_cache
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        item = data.first
        expect(item["name"]).to eq(@source.name)
        expect(item["work_count"]).to eq(10)
        expect(item["event_count"]).to eq(500)
      end
    end
  end

  context "show" do
    context "get response" do
      before(:each) do
        @source = FactoryGirl.create(:source_with_api_responses)
        @works = FactoryGirl.create_list(:work_with_events, 5)
        @source.update_cache
      end

      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v5/sources/#{@source.name}?api_key=#{user.authentication_token}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data["name"]).to eq(@source.name)
        expect(data["work_count"]).to eq(5)
        expect(data["event_count"]).to eq(250)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["status"]["stale"]).to eq(5)
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data["name"]).to eq(@source.name)
        expect(data["work_count"]).to eq(5)
        expect(data["event_count"]).to eq(250)
        expect(data["responses"]["count"]).to eq(5)
        expect(data["responses"]["average"]).to eq(200)
        expect(data["status"]["stale"]).to eq(5)
      end
    end
  end
end
