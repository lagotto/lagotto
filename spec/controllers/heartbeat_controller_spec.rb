require 'rails_helper'

describe HeartbeatController, :type => :controller do
  render_views

  context "index", :caching => true do
    it "JSON" do
      get "http://#{ENV['SERVERNAME']}/heartbeat", nil, 'HTTP_ACCEPT' => 'application/json'
      expect(last_response).to eq(200)

      response = JSON.parse(last_response.body)
      expect(response["version"]).to eq(Lagotto::VERSION)
      expect(response["works_count"]).to eq(0)
      expect(response["timestamp"]).to eq("1970-01-01T00:00:00Z")
      expect(response["status"]).to eq("stopped")
    end

    it "JSONP", :caching => true do
      get "http://#{ENV['SERVERNAME']}/heartbeat?callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
      expect(last_response).to eql(200)

      # remove jsonp wrapper
      response = JSON.parse(last_response.body[6...-1])
      expect(response["version"]).to eq(Lagotto::VERSION)
      expect(response["works_count"]).to eq(0)
      expect(response["timestamp"]).to eq("1970-01-01T00:00:00Z")
      expect(response["status"]).to eq("stopped")
    end
  end
end
