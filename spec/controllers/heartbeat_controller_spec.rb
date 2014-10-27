require 'spec_helper'

describe HeartbeatController do
  render_views

  context "index", :caching => true do
    it "JSON" do
      get "/heartbeat", nil, 'HTTP_ACCEPT' => 'application/json'
      last_response.status.should == 200

      response = JSON.parse(last_response.body)
      response["version"].should eq(Rails.application.config.version)
      response["articles_count"].should == 0
      response["update_date"].should eq("1970-01-01T00:00:00Z")
      response["status"].should eq("OK")
    end

    it "JSONP", :caching => true do
      get "/heartbeat?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
      last_response.status.should eql(200)

      # remove jsonp wrapper
      response = JSON.parse(last_response.body[6...-1])
      response["version"].should eq(Rails.application.config.version)
      response["articles_count"].should == 0
      response["update_date"].should eq("1970-01-01T00:00:00Z")
      response["status"].should eq("OK")
    end
  end
end
