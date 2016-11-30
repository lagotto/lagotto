require "rails_helper"

describe "/api/v5/article* endpoints", :type => :api do
  context "index" do

    context "/api/v5/articles (detail)" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{work.doi_escaped}&info=detail" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
        expect(item_source["events"]).not_to be_nil
      end
    end

    context "/api/v5/article/totals" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v5/article/totals?ids=#{work.doi_escaped}&info=detail" } #info param ignored

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).to be_nil
        expect(item_source["by_month"]).to be_nil
        expect(item_source["by_year"]).to be_nil
        expect(item_source["events"]).to be_nil
      end
    end

    context "/api/v5/article/views" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v5/article/views?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).to be_nil
        expect(item_source["events"]).to be_nil
      end
    end

  end
end
