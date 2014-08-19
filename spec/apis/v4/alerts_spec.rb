require "spec_helper"

describe "/api/v4/alerts" do
  let(:error) { { "total" => 0, "total_pages" => 0, "page" => 0, "error" => "You are not authorized to access this page.", "data" => [] } }
  let(:password) { user.password }
  let(:headers) { { 'HTTP_ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => "Basic " + Base64.encode64("#{CGI.escape(user.username)}:#{password}") } }

  context "index" do
    context "most recent articles" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/v4/alerts" }

      before(:each) { FactoryGirl.create_list(:alert, 55) }

      it "JSON" do
        get uri, nil, headers
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        alert = data.first
        alert["level"].should eq ("WARN")
        alert["message"].should eq ("The request timed out.")
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:uri) { "/api/v4/alerts" }

      it "JSON" do
        get uri, nil, headers
        last_response.status.should == 401

        response = JSON.parse(last_response.body)
        response.should eq (error)
      end
    end
  end
end
