require 'rails_helper'

describe User do
  let(:payload) { {"uid"=>"0000-0003-1419-2405", "api_key"=>ENV['API_KEY'], "name"=>"Martin Fenner", "email"=>nil, "role"=>"user", "iat"=>1472762438} }
  let(:token) { JWT.encode payload, ENV['JWT_SECRET_KEY'], 'HS256' }
  let(:user) { User.new((JWT.decode token, ENV['JWT_SECRET_KEY']).first) }

  subject { user }

  context "user" do
    it "has orcid" do
      expect(subject.orcid).to eq("0000-0003-1419-2405")
    end

    it "has api_key" do
      expect(user.api_key).not_to be nil
    end

    it "has role" do
      expect(subject.role).to eq("user")
    end
  end
end
