require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end
  let(:jsonp_headers) do
    { "HTTP_ACCEPT" => "application/javascript",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do

    context "more than 50 works in query" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 55) }
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v6/works?ids=#{work_list}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          work["issued"]["date-parts"][0] == [works[0].year, works[0].month, works[0].day]
        end).to be true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["works"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          work["issued"]["date-parts"][0] == [works[0].year, works[0].month, works[0].day]
        end).to be true
      end
    end

    context "default information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v6/works?ids=#{work.doi_escaped}" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end

    context "summary information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v6/works?ids=#{work.doi_escaped}&info=summary" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        expect(item["sources"]).to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        expect(item["sources"]).to be_nil
      end
    end

    context "detail information" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v6/works?ids=#{work.doi_escaped}&info=detail" }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])

        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["events"]).not_to be_nil
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["meta"]["total"]).to eq(1)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])

        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["events"]).not_to be_nil
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end

    context "by publisher" do
      let(:works) { FactoryGirl.create_list(:work_with_events, 10, publisher_id: 340) }
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v6/works?ids=#{work_list}&publisher=340" }

      it "JSON" do
        get uri, nil, headers
        work = works.first
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(10)
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        work = works.first
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["total"]).to eq(10)
        item = response["works"].first
        item = response["works"].first
        expect(item["doi"]).to eq(work.doi)
        expect(item["issued"]["date-parts"][0]).to eq([work.year, work.month, work.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["metrics"]["readers"]).to eq(work.retrieval_statuses.first.total)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end
  end
end
