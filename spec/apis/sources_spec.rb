require "rails_helper"

describe "/sources", :type => :api do
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "HTTP_AUTHORIZATION" => "Token token=#{token}" }
  end

  context "index" do
    let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"admin", "iat"=>1472762438} }
    let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
    let(:uri) { "/sources" }

    context "get response" do
      let!(:source) { FactoryGirl.create(:source) }
      let!(:datacite) { FactoryGirl.create(:source, :datacite) }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.count).to eq(2)
        item = data.last
        expect(item["id"]).to eq("datacite")
        expect(item["attributes"]["title"]).to eq("DataCite")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data.count).to eq(2)
        item = data.last
        expect(item["id"]).to eq("datacite")
        expect(item["attributes"]["title"]).to eq("DataCite")
      end
    end
  end

  context "show" do
    context "get response" do
      let(:source) { FactoryGirl.create(:source) }
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"admin", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
      let(:uri) { "/sources/#{source.name}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data["id"]).to eq("citeulike")
        expect(data["attributes"]["title"]).to eq("CiteULike")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data["id"]).to eq("citeulike")
        expect(data["attributes"]["title"]).to eq("CiteULike")
      end
    end
  end
end
