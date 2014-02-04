require "spec_helper"

describe "/api/v5/status" do

  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:uri) { "/api/v5/status?api_key=#{user.authentication_token}" }

    context "get response" do
      before(:each) do
        @articles = FactoryGirl.create_list(:article, 5)
        @api_responses = FactoryGirl.create_list(:api_response, 10)
      end

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data["articles_count"].should == 5
        data["responses_count"].should == 10
        data["users_count"].should == 1
        data["version"].should == VERSION
      end
    end
  end
end