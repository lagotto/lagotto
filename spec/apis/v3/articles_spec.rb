require "spec_helper"

describe "/api/v3/articles", :type => :api do
  
  context "index" do
    
    before(:each) do
      @articles = (1..3).collect { FactoryGirl.create(:article) } 
    end
    
    context "articles found via DOI" do
      let(:url) { "/api/v3/articles?ids=#{CGI.escape(@articles[0].doi)},#{CGI.escape(@articles[1].doi)},#{CGI.escape(@articles[2].doi)}&type=doi" }
    
      it "JSON" do
        get (url.insert 16, ".json")
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
        response_articles.any? do |a|
          a["article"]["doi"] == @articles[0].doi
        end.should be_true
      end
    
      it "XML" do
        get (url.insert 16, ".xml")
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).at_css("article doi")
        response_articles.content.should eql(@articles[0].doi)
      end
    end
    
    context "articles found via PMID" do
      let(:url) { "/api/v3/articles?ids=#{@articles[0].pub_med},#{@articles[1].pub_med},#{@articles[2].pub_med}&type=pmid" }
    
      it "JSON" do
        get (url.insert 16, ".json")
        last_response.status.should eql(200)
  
        response_articles = JSON.parse(last_response.body)
         response_articles.any? do |a|
           a["article"]["pmid"] == @articles[0].pub_med
         end.should be_true
      end
    
      it "XML" do
        get (url.insert 16, ".xml")
        last_response.status.should eql(200)
        
        response_articles = Nokogiri::XML(last_response.body).at_css("article pmid")
        response_articles.content.should eql(@articles[0].pub_med)
      end
    end
    
    context "no article found" do
      let(:url) { "/api/v3/articles"}

      it "JSON" do
        get "#{url}.json"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_json)
        last_response.status.should eql(404)
      end
    
      it "XML" do
        get "#{url}.xml"
        error = { :error => "No article found." }
        last_response.body.should eql(error.to_xml)
        last_response.status.should eql(404)
      end  
    end
  end
  
  context "show" do
    
    before(:each) do
      @article = FactoryGirl.create(:article)
    end
  
    context "DOI" do
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
  
    context "PMID" do
      let(:url) { "/api/v3/articles/info:pmid/#{@article.pub_med}"}

      it "JSON" do
        get "#{url}.json"
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmid"].should eql(@article.pub_med.to_s)
      end
    
      it "XML" do
        get "#{url}.xml"
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmid")
        response_article.content.should eql(@article.pub_med.to_s)
      end
    
    end
  
    context "PMCID" do
      let(:url) { "/api/v3/articles/info:pmcid/#{@article.pub_med_central}"}

      it "JSON" do
        get "#{url}.json"
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["pmcid"].should eql(@article.pub_med_central.to_s)
      end
    
      it "XML" do
        get "#{url}.xml"
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article pmcid")
        response_article.content.should eql(@article.pub_med_central.to_s)
      end
    
    end
  
    context "Mendeley" do
      let(:url) { "/api/v3/articles/info:mendeley/#{@article.mendeley}"}

      it "JSON" do
        get "#{url}.json"
        last_response.status.should eql(200)

        response_article = JSON.parse(last_response.body)["article"]
        response_article["mendeley"].should eql(@article.mendeley)
      end
    
      it "XML" do
        get "#{url}.xml"
        last_response.status.should eql(200)

        response_article = Nokogiri::XML(last_response.body).at_css("article mendeley")
        response_article.content.should eql(@article.mendeley)
      end
    
    end
  
    context "wrong DOI" do
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
end