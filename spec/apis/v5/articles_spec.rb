require "spec_helper"

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
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date-parts"][0] == [articles[0].year, articles[0].month, articles[0].day]
        end.should be_true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["data"]
        data.length.should == 50
        data.any? do |article|
          article["doi"] == articles[0].doi
          article["issued"]["date-parts"][0] == [articles[0].year, articles[0].month, articles[0].day]
        end.should be_true
      end
    end

    context "default information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end
    end

    context "summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&info=summary&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item["sources"].should be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item["sources"].should be_nil
      end
    end

    context "detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&info=detail&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])

        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["events"].should_not be_nil
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response["total"].should == 1
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])

        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["events"].should_not be_nil
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end
    end

    context "by publisher" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 10, publisher_id: 340) }
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v5/articles?ids=#{article_list}&publisher=340&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        article = articles.first
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        response["total"].should == 10
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, 'HTTP_ACCEPT' => 'application/javascript'
        article = articles.first
        last_response.status.should eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        response["total"].should == 10
        item = response["data"].first
        item = response["data"].first
        item["doi"].should eq(article.doi)
        item["issued"]["date-parts"][0].should eq([article.year, article.month, article.day])
        item_source = item["sources"][0]
        item_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        item_source["metrics"]["readers"].should eq(article.retrieval_statuses.first.event_count)
        item_source["by_day"].should_not be_nil
        item_source["by_month"].should_not be_nil
        item_source["by_year"].should_not be_nil
      end
    end
  end
end
