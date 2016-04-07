require "rails_helper"

describe "/api/v7/works", :type => :api do
  let(:work) { FactoryGirl.create(:work_with_private_citations, year: 2015, month: 4, day: 4) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json; version=7",
      "HTTP_AUTHORIZATION" => "Token token=#{user.api_key}" }
  end

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}&type=doi" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["DOI"]).to eq(work.doi)
        expect(item["issued"]).to eql("2015-04-04")
        expect(item["events"]["citeulike"]).to eq(work.results.first.total)
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}&type=doi" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["DOI"]).to eq(work.doi)
        expect(item["issued"]).to eql("2015-04-04")
        expect(item["events"]["citeulike"]).to eq(work.results.first.total)
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:uri) { "/api/works?ids=#{work.doi_escaped}&type=doi" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["DOI"]).to eq(work.doi)
        expect(item["issued"]).to eql("2015-04-04")
        expect(item["events"]["citeulike"]).to be_nil
      end
    end

    context "without API key" do
      let(:uri) { "/api/works?ids=#{work.doi_escaped}&type=doi" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json; version=6'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["DOI"]).to eq(work.doi)
        expect(item["issued"]).to eql("2015-04-04")
        expect(item["events"]["citeulike"]).to be_nil
      end
    end
  end
end
