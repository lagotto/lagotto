require 'spec_helper'

describe ArticlesController do
  render_views

  context "show" do
    let(:article) { FactoryGirl.create(:article_with_events) }

    it "GET DOI" do
      get "/articles/info:doi/#{article.doi}"
      last_response.status.should == 200
      last_response.body.should include(article.doi)
    end

    it "GET pmid" do
      get "/articles/info:pmid/#{article.pmid}"
      last_response.status.should == 302
      last_response.body.should include("redirected")
    end

    it "GET pmcid" do
      get "/articles/info:pmcid/PMC#{article.pmcid}"
      last_response.status.should == 302
      last_response.body.should include("redirected")
    end

    it "GET mendeley" do
      get "/articles/info:mendeley/#{article.mendeley_uuid}"
      last_response.status.should == 302
      last_response.body.should include("redirected")
    end
  end

  context "errors" do
    let(:message) { "The page you were looking for doesn't exist." }
    it "RecordNotFound error" do
      expect { get "/articles/info:doi/x" }.to raise_error(ActiveRecord::RecordNotFound)
      Alert.count.should == 0
    end

    it "RoutingError error" do
      expect { get "/x" }.to raise_error(ActionController::RoutingError)
      Alert.count.should == 0
    end
  end
end
