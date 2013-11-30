require "spec_helper"

describe "/api/v3/delayed_jobs" do

  context "index" do
    let(:user) { FactoryGirl.create(:user) }
    let(:uri) { "/api/v3/delayed_jobs?api_key=#{user.authentication_token}" }

    context "get response" do
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
        response["name"].should eq(@source.display_name)
        response["queueing_count"].should == 1
        response["stale_count"].should == 10
      end
    end
  end
end