require "spec_helper"

describe "/api/v3/articles" do
  
  context "index" do
    let(:articles) { FactoryGirl.create_list(:article, 100) }
    
    context "articles found via DOI" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.doi)}" }.join(",") 
        @uri = "/api/v3/articles?ids=#{article_list}&type=doi"
      end
    
      it "no format" do
        get @uri
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
        response_articles.any? do |a|
          a["article"]["doi"] == articles[0].doi
          a["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
      
      it "JSON" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
        response_articles.any? do |a|
          a["article"]["doi"] == articles[0].doi
          a["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    
      it "XML" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).css("article")
        response_articles.length.should eql(100)
        response_articles.first.content.should include(articles[0].doi)
      end
    end
          
    context "articles found via PMID" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.pub_med)}" }.join(",") 
        @uri = "/api/v3/articles?ids=#{article_list}&type=pmid"
      end

    
      it "JSON" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
         response_articles.any? do |a|
           a["article"]["pmid"] == articles[0].pub_med
         end.should be_true
      end
    
      it "XML" do
        get @uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).css("article")
        response_articles.length.should eql(100)
        response_articles.first.content.should include(articles[0].pub_med)
      end
    end
    
    context "no article found" do
      let(:uri) { "/api/v3/articles"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_xml)
        last_response.status.should eql(404)
      end  
    end
    
  end
  
  context "show" do
  
    context "DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "no format" do
        get uri
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
      
      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
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
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    
    end
  
    context "PMID" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:pmid/#{article.pub_med}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmid"].should eql(article.pub_med.to_s)
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmid")
        response_article.content.should eql(article.pub_med.to_s)
      end
    
    end
  
    context "PMCID" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:pmcid/PMC#{article.pub_med_central}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmcid"].should eql(article.pub_med_central.to_s)
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmcid")
        response_article.content.should eql(article.pub_med_central.to_s)
      end
    
    end
  
    context "Mendeley" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:mendeley/#{article.mendeley}"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["mendeley"].should eql(article.mendeley)
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article mendeley")
        response_article.content.should eql(article.mendeley)
      end
    
    end
      
    context "wrong DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}xx"}

      it "JSON" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_xml)
        last_response.status.should eql(404)
      end  
    end
    
    context "article not found when using format as file extension" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}xx"}

      it "JSON" do
        get "#{uri}.json"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get "#{uri}.xml"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end  
    end
     
  end
end