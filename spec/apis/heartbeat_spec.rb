require "rails_helper"

describe "/heartbeat", :type => :api do
  context "index" do
    let(:uri) { "http://#{ENV['HOSTNAME']}/heartbeat" }

    it "JSON" do
      get uri
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end
end
