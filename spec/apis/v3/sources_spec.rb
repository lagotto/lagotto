require "spec_helper"

describe "/api/v3/sources" do

  context "show" do
    context "get response" do
      before(:each) do
        @delayed_job = FactoryGirl.create(:delayed_job)
        @articles = FactoryGirl.create_list(:article_with_events, 5)
        @api_responses = FactoryGirl.create_list(:api_response, 10)
      end

      let(:user) { FactoryGirl.create(:user) }
      let(:source) { FactoryGirl.create(:source) }
      let(:uri) { "/api/v3/sources/#{source.name}?api_key=#{user.authentication_token}" }

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response = JSON.parse(last_response.body)
        response["name"].should eq(source.display_name)
        response["article_count"].should == 5
        response["event_count"].should == 250
        response["responses_count"].should == 10
        response["average_count"].should == 200
        response["status"][0]["value"].should == 5
      end
    end
  end
end