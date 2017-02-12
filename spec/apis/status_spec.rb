require "rails_helper"

describe "/status", :type => :api do
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
    let(:uri) { "/status" }
    let!(:source) { FactoryGirl.create(:source) }
    let!(:deposits) { FactoryGirl.create_list(:deposit, 5) }
    let!(:works) { FactoryGirl.create_list(:work, 10) }

    context "as admin user" do
      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data["attributes"]["state"]).to eq("waiting")
      end

      it "JSONP" do
        get "#{uri}?callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data["attributes"]["state"]).to eq("waiting")
      end
    end

    context "as regular user" do
      let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
      let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
      let(:errors) { [{"status"=>"401", "title"=>"You are not authorized to access this resource."}] }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(401)

        response = JSON.parse(last_response.body)
        expect(response["errors"]).to eq(errors)
        expect(response["data"]).to be_blank
      end
    end
  end
end
