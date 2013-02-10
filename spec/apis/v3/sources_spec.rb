require "spec_helper"

describe "/api/v3/articles" do   
  context "metrics for CiteULike" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

    it "JSON" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eq(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
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
      get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      last_response.status.should eql(200)
      
      response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      response = response["articles"]["article"]
      response_source = response["sources"]["source"]
      response["doi"].should eql(article.doi)
      response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].should be_nil
      response_source["metrics"]["groups"].should be_nil
      response_source["metrics"]["html"].should be_nil
      response_source["metrics"]["likes"].should be_nil
      response_source["metrics"]["pdf"].should be_nil
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
    
  end  
    
  context "metrics for CrossRef" do
    let(:article) { FactoryGirl.create(:article_with_crossref_citations) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

    it "JSON" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.event_count)
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
      get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      last_response.status.should eql(200)

      response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      response = response["articles"]["article"]
      response_source = response["sources"]["source"]
      response["doi"].should eql(article.doi)
      response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should be_nil
      response_source["metrics"]["groups"].should be_nil
      response_source["metrics"]["html"].should be_nil
      response_source["metrics"]["likes"].should be_nil
      response_source["metrics"]["pdf"].should be_nil
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
  end    
    
  context "metrics for PubMed" do
    let(:article) { FactoryGirl.create(:article_with_pubmed_citations) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

    it "JSON" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.event_count)
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
      get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      last_response.status.should eql(200)

      response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      response = response["articles"]["article"]
      response_source = response["sources"]["source"]
      response["doi"].should eql(article.doi)
      response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should be_nil
      response_source["metrics"]["groups"].should be_nil
      response_source["metrics"]["html"].should be_nil
      response_source["metrics"]["likes"].should be_nil
      response_source["metrics"]["pdf"].should be_nil
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
  end  
    
  context "metrics for Nature" do
    let(:article) { FactoryGirl.create(:article_with_nature_citations) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

    it "JSON" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.event_count)
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
      get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      last_response.status.should eql(200)

      response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      response = response["articles"]["article"]
      response_source = response["sources"]["source"]
      response["doi"].should eql(article.doi)
      response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should be_nil
      response_source["metrics"]["groups"].should be_nil
      response_source["metrics"]["html"].should be_nil
      response_source["metrics"]["likes"].should be_nil
      response_source["metrics"]["pdf"].should be_nil
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
  end    
    
  context "metrics for Research Blogging" do
    let(:article) { FactoryGirl.create(:article_with_researchblogging_citations) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}

    it "JSON" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].should eq(article.retrieval_statuses.first.event_count)
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
      get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      last_response.status.should eql(200)

      response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      response = response["articles"]["article"]
      response_source = response["sources"]["source"]
      response["doi"].should eql(article.doi)
      response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["citations"].to_i.should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should be_nil
      response_source["metrics"]["groups"].should be_nil
      response_source["metrics"]["html"].should be_nil
      response_source["metrics"]["likes"].should be_nil
      response_source["metrics"]["pdf"].should be_nil
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
  end    
  
  context "metrics for a specific source" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?source=citeulike"}

    it "Citeulike" do
      get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)[0]
      response_source = response_article["sources"][0]
      response_article["doi"].should eql(article.doi)
      response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"]["shares"].should eq(article.retrieval_statuses.first.event_count)
      response_source["metrics"].should include("comments")
      response_source["metrics"].should include("groups")
      response_source["metrics"].should include("html")
      response_source["metrics"].should include("likes")
      response_source["metrics"].should include("pdf")
      response_source["metrics"].should include("citations")
      response_source["events"].should be_nil
      response_source["histories"].should be_nil
    end
  end  
end