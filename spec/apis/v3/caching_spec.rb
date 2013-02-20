require "spec_helper"

describe "/api/v3/articles" do
  context "caching", :caching => true do
    
    context "index" do
      let(:articles) { FactoryGirl.create_list(:article_with_events, 50) }      
    end
    
    context "show" do
      # let(:article) { FactoryGirl.create(:article_with_events) }
      # let(:uri) { "/api/v3/articles/info:doi/#{article.doi}"}
      # let(:key) { ArticleDecorator.decorate(article) }
      # 
      # #rabl/articles/7-20130219192137//json
      # #key = ["user_#{@user.fbid}", @user]
      # #Rails.cache.read(ActiveSupport::Cache.expand_cache_key(key, :rabl))
      # 
      # it "JSON after XML" do
      #   get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      #   last_response.status.should eql(200)
      #   #Rails.cache.exist?(key).should_not be_true
      #   #ActionController::Base.cache_store.exist?.should be_false
      #   
      #   get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      #   last_response.status.should eql(200)
      #   
      #   get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      #   last_response.status.should eql(200)
      #   #Rails.cache.exist?(key).should be_true
      #   Rails.cache.read(ActiveSupport::Cache.expand_cache_key(key, :rabl)).should eq(2)
      #     
      #   response_article = JSON.parse(last_response.body)[0]
      #   response_source = response_article["sources"][0]
      #   response_article["doi"].should eql(article.doi)
      #   response_article["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      #   response_source["metrics"]["total"].should eq(article.retrieval_statuses.first.event_count)
      #   response_source["events"].should be_nil
      #   response_source["histories"].should be_nil
      # end
      #     
      # it "XML after JSON" do
      #   get uri, nil, { 'HTTP_ACCEPT' => "application/json" }
      #   get uri, nil, { 'HTTP_ACCEPT' => "application/xml" }
      #   last_response.status.should eql(200)
      #   
      #   response = Nori.new(:advanced_typecasting => false).parse(last_response.body)
      #   response = response["articles"]["article"]
      #   response_source = response["sources"]["source"]
      #   response["doi"].should eql(article.doi)
      #   response["publication_date"].should eql(article.published_on.to_time.utc.iso8601)
      #   response_source["metrics"]["total"].to_i.should eq(article.retrieval_statuses.first.event_count)
      #   response_source["events"].should be_nil
      #   response_source["histories"].should be_nil
      # end
    end
  end
end