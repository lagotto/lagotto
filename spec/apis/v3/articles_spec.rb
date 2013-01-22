require "spec_helper"

describe "/api/v3/articles" do
  
  context "index" do
    let(:articles) { FactoryGirl.create_list(:article, 55) }
    
    context "more than 50 articles in query" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.doi)}" }.join(",") 
        @uri = "/api/v3/articles?ids=#{article_list}&type=doi"
      end
      
      it "JSON" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(50)
        response_articles.any? do |article|
          article["article"]["doi"] == articles[0].doi
          article["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    
      it "XML" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response = Nori.new.parse(last_response.body)
        response = response["articles"]
        response.length.should eql(50)
        response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    end
  end
  
  context "show" do
    
    context "show summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=summary"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_article["sources"].should be_nil
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should_not include(article.sources.first.name)
      end
    end
  
    context "historical data after 110 days" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?days=110"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_days(110).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.after_days(110).last.event_count)
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    
    end
  
    context "historical data after 4 months" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?months=4"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.after_months(4).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.after_months(4).last.event_count)
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end 
    
    context "historical data until 2012" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?year=2013"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.until_year(2013).last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.until_year(2013).last.event_count)
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end 
    
    context "show detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=detail"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.metrics[:shares])
        #response_source["events"].should_not be_nil
        response_source["histories"].should_not be_nil

      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics").should_not be_nil
        response_source.at_css("events").should_not be_nil
        response_source.at_css("histories").should_not be_nil
      end
    
    end
    
    context "show history information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=history"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should_not be_nil

      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should_not be_nil
      end
    
    end
    
    context "show event information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?info=event"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.metrics[:shares])
        #response_source["events"].should_not be_nil
        response_source["histories"].should be_nil

      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics").should_not be_nil
        response_source.at_css("events").should_not be_nil
        response_source.at_css("histories").should be_nil
      end
    
    end    
  end
end