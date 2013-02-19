require 'spec_helper'

describe ArticlesController do
  render_views
  
  context "show" do
    let(:article) { FactoryGirl.create(:article) }  
  
    it "GET DOI" do
      get "/articles/info:doi/#{article.doi}"
      last_response.status.should eql(200)
      last_response.body.should include(article.doi)
    end
  
    it "GET pmid" do
      get "/articles/info:pmid/#{article.pub_med}"
      last_response.status.should eql(200)
      last_response.body.should include(article.pub_med.to_s)
    end
  
    it "GET pmcid" do
      get "/articles/info:pmcid/PMC#{article.pub_med_central}"
      last_response.status.should eql(200)
      last_response.body.should include(article.pub_med_central.to_s)
    end
  
    it "GET mendeley" do
      get "/articles/info:mendeley/#{article.mendeley}"
      last_response.status.should eql(200)
      last_response.body.should include(article.mendeley)
    end
  end
  
  context "errors" do
    let(:message) { "The page you were looking for doesn't exist." }
    it "RecordNotFound error" do
      expect { get "/articles/info:doi/x" }.to raise_error(ActiveRecord::RecordNotFound) 
      ErrorMessage.count.should eq(0)
    end
    
    it "RoutingError error" do
      expect { get "/x" }.to raise_error(ActionController::RoutingError) 
      ErrorMessage.count.should eq(0)
    end
  end
end