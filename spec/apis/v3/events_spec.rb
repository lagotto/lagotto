require "spec_helper"

describe "/api/v3/events" do

  context "index" do
    let(:user) { FactoryGirl.create(:user) }
    let(:uri) { "/api/v3/events?api_key=#{user.authentication_token}" }

    context "get response" do
      before(:each) do
        @source = FactoryGirl.create(:source)
        @articles = FactoryGirl.create_list(:article_with_events, 10)
      end

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        responses = JSON.parse(last_response.body)
        response = responses.first
        response["name"].should eq(@source.display_name)
        response["article_count"].should == 10
        response["event_count"].should == 500
      end
    end
  end
end