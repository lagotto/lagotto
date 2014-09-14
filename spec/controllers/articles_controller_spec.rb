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
      last_response.status.should == 200
      last_response.body.should include(article.pmid)
    end

    it "GET pmcid" do
      get "/articles/info:pmcid/PMC#{article.pmcid}"
      last_response.status.should == 200
      last_response.body.should include(article.pmcid.to_s)
    end
  end

  context "errors" do
    it "redirects to the home page for an unknown article" do
      get "/articles/info:doi/x"
      last_response.status.should eql(404)
      last_response.body.should include("redirected")
    end

    it "redirects to the home page for an unknown path" do
      get "/x"
      last_response.status.should eql(404)
      last_response.body.should include("redirected")
    end
  end
end
