require "spec_helper"

describe "/api/v3/sources" do
  context "index" do
    let(:user) { FactoryGirl.create(:user) }
    let(:uri) { "/api/v3/sources?api_key=#{user.authentication_token}" }

    context "get jobs" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @delayed_job = FactoryGirl.create(:delayed_job)
        @articles = FactoryGirl.create_list(:article_with_events, 10)
      end

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        responses = JSON.parse(last_response.body)
        response = responses.first
        response["name"].should eq(@source.name)
        response["queueing_count"].should == 1
        response["stale_count"].should == 10
      end
    end

    context "get responses" do
      before(:each) do
        @source = FactoryGirl.create(:source_with_api_responses)
      end

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        responses = JSON.parse(last_response.body)
        response = responses.first
        response["name"].should eq(@source.name)
        response["response_count"].should == 5
        response["average_count"].should == 200
      end
    end

    context "get events" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @articles = FactoryGirl.create_list(:article_with_events, 10)
      end

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        responses = JSON.parse(last_response.body)
        response = responses.first
        response["name"].should eq(@source.name)
        response["article_count"].should == 10
        response["event_count"].should == 500
      end
    end
  end

  context "show" do
    context "get response" do
      before(:each) do
        @delayed_job = FactoryGirl.create(:delayed_job)
        @articles = FactoryGirl.create_list(:article_with_events, 5)
      end

      let(:user) { FactoryGirl.create(:user) }
      let(:source) { FactoryGirl.create(:source_with_api_responses) }
      let(:uri) { "/api/v3/sources/#{source.name}?api_key=#{user.authentication_token}" }

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response["name"].should eq(source.name)
        response["article_count"].should == 5
        response["event_count"].should == 250
        response["response_count"].should == 5
        response["average_count"].should == 200
        response["status"][0]["value"].should == 5


        response["queueing_count"].should == 1
        response["stale_count"].should == 5
      end
    end
  end
end