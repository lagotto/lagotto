require "rails_helper"

describe "/api/v5/articles", :type => :api do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{work.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]).to include("comments")
        expect(item_source["metrics"]).to include("likes")
        expect(item_source["metrics"]).to include("html")
        expect(item_source["metrics"]).to include("pdf")
        expect(item_source["metrics"]).not_to include("citations")
        expect(item_source["events"]).to be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{work.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]).to include("comments")
        expect(item_source["metrics"]).to include("likes")
        expect(item_source["metrics"]).to include("html")
        expect(item_source["metrics"]).to include("pdf")
        expect(item_source["metrics"]).not_to include("citations")
        expect(item_source["events"]).to be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{work.doi_escaped}&api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["sources"]).to be_empty
      end
    end

    context "without API key" do
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v5/articles?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eql(work.doi)
        expect(item["issued"]["date-parts"][0]).to eql([work.year, work.month, work.day])
        expect(item["sources"]).to be_empty
      end
    end
  end
end
