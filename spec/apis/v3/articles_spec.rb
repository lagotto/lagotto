require "spec_helper"

describe "/api/v3/articles", :type => :api do
  
  context "index" do
    let(:articles) { FactoryGirl.create_list(:article, 100) }
    
    context "articles found via DOI" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.doi)}" }.join(",") 
        @url = "/api/v3/articles?ids=#{article_list}&type=doi"
      end
    
      it "no format" do
        get @url
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
        response_articles.any? do |a|
          a["article"]["doi"] == articles[0].doi
          a["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
      
      it "JSON" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
        response_articles.any? do |a|
          a["article"]["doi"] == articles[0].doi
          a["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    
      it "XML" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).css("article")
        response_articles.length.should eql(100)
        response_articles.first.content.should include(articles[0].doi)
      end
    end
          
    context "articles found via PMID" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.pub_med)}" }.join(",") 
        @url = "/api/v3/articles?ids=#{article_list}&type=pmid"
      end

    
      it "JSON" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
         response_articles.any? do |a|
           a["article"]["pmid"] == articles[0].pub_med
         end.should be_true
      end
    
      it "XML" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).css("article")
        response_articles.length.should eql(100)
        response_articles.first.content.should include(articles[0].pub_med)
      end
    end
    
    context "no article found" do
      let(:url) { "/api/v3/articles"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_xml)
        last_response.status.should eql(404)
      end  
    end
    
  end
  
  context "index" do
    let(:articles) { FactoryGirl.create_list(:article, 110) }
    
    context "more than 100 articles in query" do
      before(:each) do
        article_list = articles.collect { |article| "#{CGI.escape(article.doi)}" }.join(",") 
        @url = "/api/v3/articles?ids=#{article_list}&type=doi"
      end
      
      it "JSON" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.length.should eql(100)
        response_articles.any? do |a|
          a["article"]["doi"] == articles[0].doi
          a["article"]["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end.should be_true
      end
    
      it "XML" do
        get @url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).css("article")
        response_articles.length.should eql(100)
        response_articles.first.content.should include(articles[0].doi)
      end
    end
  end
  
  context "show" do
  
    context "DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "no format" do
        get url
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
      
      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
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
      let(:url) { "/api/v3/articles/info:pmid/#{article.pub_med}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmid"].should eql(article.pub_med.to_s)
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmid")
        response_article.content.should eql(article.pub_med.to_s)
      end
    
    end
  
    context "PMCID" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:pmcid/#{article.pub_med_central}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmcid"].should eql(article.pub_med_central.to_s)
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmcid")
        response_article.content.should eql(article.pub_med_central.to_s)
      end
    
    end
  
    context "Mendeley" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:mendeley/#{article.mendeley}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["mendeley"].should eql(article.mendeley)
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article mendeley")
        response_article.content.should eql(article.mendeley)
      end
    
    end
      
    context "wrong DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}xx"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_xml)
        last_response.status.should eql(404)
      end  
    end
    
    context "article not found when using format as file extension" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}xx"}

      it "JSON" do
        get "#{url}.json"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get "#{url}.xml"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end  
    end
    
    context "show summary information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}?info=summary"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_article["sources"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should_not include(article.sources.first.name)
      end
    end
    
    context "show detail information" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}?info=detail"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["events"].should_not be_nil
        response_source["histories"].should_not be_nil

      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
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
  
    context "historical data after 110 days" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}?days=110"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
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
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
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
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}?months=4"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
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
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
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
    
    context "metrics for CiteULike" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"].should include("citations")
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics shares").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics citations").should_not be_nil
        response_source.at_css("metrics comments").should_not be_nil
        response_source.at_css("metrics groups").should_not be_nil
        response_source.at_css("metrics html").should_not be_nil
        response_source.at_css("metrics likes").should_not be_nil
        response_source.at_css("metrics pdf").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    
    end  
    
    context "metrics for CrossRef" do
      let(:article) { FactoryGirl.create(:article_with_crossref_citations) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["metrics"].should include("shares")
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics citations").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics comments").should_not be_nil
        response_source.at_css("metrics groups").should_not be_nil
        response_source.at_css("metrics html").should_not be_nil
        response_source.at_css("metrics likes").should_not be_nil
        response_source.at_css("metrics pdf").should_not be_nil
        response_source.at_css("metrics citations").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end    
    
    context "metrics for PubMed" do
      let(:article) { FactoryGirl.create(:article_with_pubmed_citations) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["metrics"].should include("shares")
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics citations").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics comments").should_not be_nil
        response_source.at_css("metrics groups").should_not be_nil
        response_source.at_css("metrics html").should_not be_nil
        response_source.at_css("metrics likes").should_not be_nil
        response_source.at_css("metrics pdf").should_not be_nil
        response_source.at_css("metrics citations").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end  
    
    context "metrics for Nature" do
      let(:article) { FactoryGirl.create(:article_with_nature_citations) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["metrics"].should include("shares")
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics citations").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics comments").should_not be_nil
        response_source.at_css("metrics groups").should_not be_nil
        response_source.at_css("metrics html").should_not be_nil
        response_source.at_css("metrics likes").should_not be_nil
        response_source.at_css("metrics pdf").should_not be_nil
        response_source.at_css("metrics citations").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end    
    
    context "metrics for Research Blogging" do
      let(:article) { FactoryGirl.create(:article_with_researchblogging_citations) }
      let(:url) { "/api/v3/articles/info:doi/#{article.doi}"}

      it "JSON" do
        get url, nil, { 'HTTP_ACCEPT' => "application/json" }
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_source = response_article["sources"][0]["source"]
        response_article["doi"].should eql(article.doi)
        response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
        response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source["metrics"].should include("comments")
        response_source["metrics"].should include("groups")
        response_source["metrics"].should include("html")
        response_source["metrics"].should include("likes")
        response_source["metrics"].should include("pdf")
        response_source["metrics"].should include("shares")
        response_source["events"].should be_nil
        response_source["histories"].should be_nil
      end
    
      it "XML" do
        get url, nil, { 'HTTP_ACCEPT' => "application/xml" }
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article")
        response_source = response_article.at_css("sources source")
        response_article.content.should include(article.doi)
        response_article.content.should include(article.published_on.to_time.utc.iso8601)
        response_article.content.should include(article.sources.first.name)
        response_source.at_css("metrics total").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics citations").content.to_i.should eq(article.retrieval_statuses.first.retrieval_histories.last.event_count)
        response_source.at_css("metrics comments").should_not be_nil
        response_source.at_css("metrics groups").should_not be_nil
        response_source.at_css("metrics html").should_not be_nil
        response_source.at_css("metrics likes").should_not be_nil
        response_source.at_css("metrics pdf").should_not be_nil
        response_source.at_css("metrics citations").should_not be_nil
        response_source.at_css("events").should be_nil
        response_source.at_css("histories").should be_nil
      end
    end      
  end
end