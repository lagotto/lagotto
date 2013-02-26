require "spec_helper"

describe "/api/v3/articles" do
  context "caching", :caching => true do
    
    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 10) }
      
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.doi)}" }.join(",") 
        @uri = "/api/v3/articles?ids=#{article_list}&type=doi"
      end   
      
      it "can cache articles in JSON" do
        articles.any? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//json")
        end.should_not be_true
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        articles.all? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//json")
        end.should be_true
        
        article = articles.first
        response = Rails.cache.read("rabl/#{ArticleDecorator.decorate(article).cache_key}//json")
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:publication_date].should eql(article.published_on.to_time.utc.iso8601)
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
        response_source[:histories].should be_nil
      end
      
      it "can cache articles in XML" do
        articles.any? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//xml")
        end.should_not be_true
        get @uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        articles.all? do |article|
          Rails.cache.exist?("rabl/#{ArticleDecorator.decorate(article).cache_key}//xml")
        end.should be_true
        
        article = articles.first
        response = Rails.cache.read("rabl/#{ArticleDecorator.decorate(article).cache_key}//xml")
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:publication_date].should eql(article.published_on.to_time.utc.iso8601)
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
        response_source[:histories].should be_nil
      end
      
      it "can make API requests 6x faster" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        ApiRequest.count.should eql(2)
        ApiRequest.last.page_duration.should be < 0.17 * ApiRequest.first.page_duration
      end
    end
    
    context "show" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}
      let(:key) { "rabl/#{ArticleDecorator.decorate(article).cache_key}" }
      let(:title) { "Foo" }
      let(:event_count) { 75 }
      
      it "can cache an article in JSON" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        response = Rails.cache.read("#{key}//json")
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:publication_date].should eql(article.published_on.to_time.utc.iso8601)
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
        response_source[:histories].should be_nil
      end
      
      it "can cache an article in XML" do
        Rails.cache.exist?("#{key}//xml").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//xml").should be_true
        
        response = Rails.cache.read("#{key}//xml")
        response_source = response[:sources][0]
        response[:doi].should eql(article.doi)
        response[:publication_date].should eql(article.published_on.to_time.utc.iso8601)
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:events].should be_nil
        response_source[:histories].should be_nil
      end
      
      it "can cache JSON and XML separately" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should_not be_true
        Rails.cache.exist?("#{key}//xml").should be_true
      end
      
      it "can make API requests 3x faster" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        ApiRequest.count.should eql(2)
        ApiRequest.last.page_duration.should be < 0.33 * ApiRequest.first.page_duration
      end
          
      it "does not use a stale cache when an article is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response[:title].should eql(article.title)
        response[:title].should_not eql(title)
        
        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.update_attributes!({ :title => title })
        
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        cache_key = "rabl/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response[:title].should eql(article.title)
        response[:title].should eql(title)
      end
      
      it "does not use a stale cache when a source is updated" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response_source = response[:sources][0]
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:metrics][:total].should_not eql(event_count)
            
        # wait a second so that the timestamp for cache_key is different
        sleep 1
        article.retrieval_statuses.first.update_attributes!({ :event_count => event_count })
        # TODO make sure that touch works in production
        article.touch
        
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        cache_key = "rabl/#{ArticleDecorator.decorate(article).cache_key}"
        cache_key.should_not eql(key)
        Rails.cache.exist?("#{cache_key}//json").should be_true
        response = Rails.cache.read("#{cache_key}//json")
        response_source = response[:sources][0]
        response_source[:metrics][:total].should eql(article.retrieval_statuses.first.event_count)
        response_source[:metrics][:total].should eql(event_count)
      end
      
      it "does not use a stale cache when the source query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        response = Rails.cache.read("#{key}//json")
        response[:sources].size.should eql(1)
        
        source_uri = "#{uri}?source=crossref"
        get source_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(404)
        JSON.parse(last_response.body).should eql({"error"=>"No article found."})
      end 
      
      it "does not use a stale cache when the info query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        history_uri = "#{uri}?info=history"
        get history_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should_not be_nil
        
        summary_uri = "#{uri}?info=summary"
        get summary_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        response = JSON.parse(last_response.body)[0]
        response["sources"].should be_nil
        response["doi"].should eql(article.doi)
        response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      end   
      
      it "does not use a stale cache when the days query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        days_uri = "#{uri}?days=110"
        get days_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        response_article = JSON.parse(last_response.body)[0]
        response_source = response_article["sources"][0]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_days(110).first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end 
      
      it "does not use a stale cache when the months query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        months_uri = "#{uri}?months=4"
        get months_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        response_article = JSON.parse(last_response.body)[0]
        response_source = response_article["sources"][0]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_months(4).first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end   
      
      it "does not use a stale cache when the year query parameter changes" do
        Rails.cache.exist?("#{key}//json").should_not be_true
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        Rails.cache.exist?("#{key}//json").should be_true
        
        year_uri = "#{uri}?year=2013"
        get year_uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
        
        response_article = JSON.parse(last_response.body)[0]
        response_source = response_article["sources"][0]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.until_year(2013).first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end     
      
    end
  end
end