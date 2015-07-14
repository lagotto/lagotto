require "rails_helper"

describe "/api/v6/publishers", :type => :api do
  context "index" do
    let(:user) { FactoryGirl.create(:admin_user) }
    let(:headers) do
      { "HTTP_ACCEPT" => "application/json; version=6",
        "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
    end
    let(:jsonp_headers) do
      { "HTTP_ACCEPT" => "application/javascript; version=6",
        "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
    end
    let(:uri) { "/api/publishers" }

    context "index" do
      let!(:publisher) { FactoryGirl.create(:publisher) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["publishers"]
        item = data.first
        expect(item["title"]).to eq(publisher.title)
        expect(item["id"]).to eq(publisher.member_id)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["publishers"]
        item = data.first
        expect(item["title"]).to eq(publisher.title)
        expect(item["id"]).to eq(publisher.name)
        expect(item["other_names"]).to eq(["Public Library of Science",
                                       "Public Library of Science (PLoS)"])
        expect(item["prefixes"]).to eq(["10.1371"])
      end
    end
  end
end
