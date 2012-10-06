require "spec_helper"

describe "/api/v3/articles", :type => :api do
  
  before do
    @article = FactoryGirl.create(:article)
  end
  
  context "index" do
  
    let(:url) { "/api/v3/articles" }
    
    it "JSON" do
      get "#{url}.json"
      last_response.status.should eql(200)
  
      response_articles = JSON.parse(last_response.body)
      response_articles.any? do |a|
        a["article"]["doi"] == @article.doi
      end.should be_true
    end
    
    it "XML" do
      get "#{url}.xml"
      last_response.status.should eql(200)
      
      response_articles = Nokogiri::XML(last_response.body).at_css("article doi")
      response_articles.content.should eql(@article.doi)
    end
  end
  
  context "show" do
    let(:url) { "/api/v3/articles/info:doi/#{@article.doi}"}

    it "JSON" do
      get "#{url}.json"
      last_response.status.should eql(200)

      response_article = JSON.parse(last_response.body)["article"]
      response_article["doi"].should eql(@article.doi)
    end
    
    it "XML" do
      get "#{url}.xml"
      last_response.status.should eql(200)

      response_article = Nokogiri::XML(last_response.body).at_css("article doi")
      response_article.content.should eql(@article.doi)
    end
    
  end
  
  context "show with wrong doi" do
    let(:url) { "/api/v3/articles/info:doi/#{@article.doi}xx"}

    it "JSON" do
      get "#{url}.json"
      error = { :error => "Article not found." }
      last_response.body.should eql(error.to_json)
      last_response.status.should eql(404)
    end
    
    it "XML" do
      get "#{url}.xml"
      error = { :error => "Article not found." }
      last_response.body.should eql(error.to_xml)
      last_response.status.should eql(404)
    end  
  end
end