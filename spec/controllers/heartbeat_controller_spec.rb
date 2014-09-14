require 'spec_helper'

describe HeartbeatController do
  render_views

  context "index" do
    it "JSON" do
      get "/heartbeat", nil, 'HTTP_ACCEPT' => 'application/json'
      last_response.status.should == 200

      response = JSON.parse(last_response.body)
      response["version"].should eq(Rails.application.config.version)
      response["articles_count"].should == 0
      response["update_date"].should eq (Rails.cache.fetch("status:timestamp"))
      response["status"].should eq("OK")
    end

    it "JSONP" do
      get "/heartbeat?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
      last_response.status.should eql(200)

      # remove jsonp wrapper
      response = JSON.parse(last_response.body[6...-1])
      response["version"].should eq(Rails.application.config.version)
      response["articles_count"].should == 0
      response["update_date"].should eq (Rails.cache.fetch("status:timestamp"))
      response["status"].should eq("OK")
    end
  end
end
