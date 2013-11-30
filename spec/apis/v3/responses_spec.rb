require "spec_helper"

describe "/api/v3/responses" do

  context "index" do
    context "get response" do
      before do
        @source = FactoryGirl.create(:source)
        @api_responses = FactoryGirl.create_list(:api_response, 10)
      end

      let(:user) { FactoryGirl.create(:user) }
      let(:uri) { "/api/v3/responses?api_key=#{user.authentication_token}" }

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        responses = JSON.parse(last_response.body)
        response = responses.first
        response["name"].should eq(@source.display_name)
        response["response_count"].should == 10
        response["response_duration"].should == 200
      end
    end
  end
end