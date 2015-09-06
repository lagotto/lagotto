require "rails_helper"

describe "/heartbeat", :type => :api do
  context "index" do
    let(:uri) { "http://#{ENV['HOSTNAME']}/heartbeat" }

    it "JSON" do
      get uri
      expect(last_response.status).to eq(200)

      response = JSON.parse(last_response.body)
      status = response["status"]
      expect(status).to eq(10)
    end
  end
end
