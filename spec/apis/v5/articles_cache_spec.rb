require "spec_helper"

describe "/api/v5/articles", :not_teamcity => true do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }

  context "caching", :caching => true do

    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 2) }
      let(:article_list) { articles.collect { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v5/articles?ids=#{article_list}&type=doi&api_key=#{api_key}" }

      it "can cache articles in JSON" do
        articles.any? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//json")
        end.should_not be_true

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        articles.all? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//json")
        end.should be_true

        article = articles.first
        response = JSON.parse(Rails.cache.read("rabl/#{ArticleDecorator.decorate(article).cache_key}//json"))
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:issued][:date_parts].should eql([article.year, article.month, article.day])
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
      end

      it "can make API requests 2x faster" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        ApiRequest.count.should eql(2)
        ApiRequest.last.view_duration.should be < 0.5 * ApiRequest.first.view_duration
      end
    end

    context "article is updated" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v5/articles?ids=#{article.doi_escaped}&api_key=#{api_key}"}
      let(:key) { "rabl/#{ArticleDecorator.decorate(article).cache_key}" }
      let(:title) { "Foo" }
      let(:event_count) { 75 }

      it "does not use a stale cache when an article is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"][0]
        data["title"].should eql(article.title)
        data["title"].should_not eql(title)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.update_attributes!({ :title => title })

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        cache_key = "rabl/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{cache_key}//json"))
        data = response["data"][0]
        data["title"].should eql(article.title)
        data["title"].should eql(title)
      end

      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"][0]
        response_source = data["sources"][0]
        response_source["metrics"]["total"].should eql(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["total"].should_not eql(event_count)

        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.retrieval_statuses.first.update_attributes!({ :event_count => event_count })
        # TODO make sure that touch works in production
        article.touch

        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        cache_key = "rabl/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{cache_key}//json"))
        data = response["data"][0]
        response_source = data["sources"][0]
        response_source["metrics"]["total"].should eql(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["total"].should eql(event_count)
      end

      it "does not use a stale cache when the source query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true
        response = JSON.parse(Rails.cache.read("#{key}//json"))
        data = response["data"][0]
        data["sources"].size.should == 1

        source_uri = "#{uri}&source=crossref"
        get source_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200
        JSON.parse(last_response.body).should eql("total" => 0, "total_pages" => 0, "page" => 0, "error" => nil, "data" =>[])
      end

      it "does not use a stale cache when the info query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        sleep 1

        Rails.cache.exist?("#{key}//json").should be_true

        detail_uri = "#{uri}&info=detail"
        get detail_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        data["doi"].should eql(article.doi)
        data["issued"]["date_parts"].should eql([article.year, article.month, article.day])

        response_source = data["sources"][0]
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should_not be_nil

        summary_uri = "#{uri}&info=summary"
        get summary_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should == 200

        response = JSON.parse(last_response.body)
        data = response["data"][0]
        data["sources"].should be_nil
        data["doi"].should eql(article.doi)
        data["issued"]["date_parts"].should eql([article.year, article.month, article.day])
      end
    end
  end
end
