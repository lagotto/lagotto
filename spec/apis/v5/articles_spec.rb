require "rails_helper"

describe "/api/v5/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "index" do

    context "more than 50 articles in query" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 55) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v5/articles?ids=#{article_list}&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date-parts"][0] == [articles[0].year, articles[0].month, articles[0].day]
        end).to be true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date-parts"][0] == [articles[0].year, articles[0].month, articles[0].day]
        end).to be true
      end
    end

    context "default information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end

    context "summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&info=summary&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        expect(item["sources"]).to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        expect(item["sources"]).to be_nil
      end
    end

    context "detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&info=detail&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])

        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["events"]).not_to be_nil
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["total"]).to eq(1)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])

        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["events"]).not_to be_nil
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end

    context "by publisher" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 10, publisher_id: 340) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v5/articles?ids=#{article_list}&publisher=340&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        article = articles.first
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        expect(response["total"]).to eq(10)
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        article = articles.first
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        expect(response["total"]).to eq(10)
        item = response["data"].first
        item = response["data"].first
        expect(item["doi"]).to eq(article.doi)
        expect(item["issued"]["date-parts"][0]).to eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        expect(item_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["metrics"]["readers"]).to eq(article.retrieval_statuses.first.event_count)
        expect(item_source["by_day"]).not_to be_nil
        expect(item_source["by_month"]).not_to be_nil
        expect(item_source["by_year"]).not_to be_nil
      end
    end
  end
end
