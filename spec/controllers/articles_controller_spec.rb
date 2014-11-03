require "rails_helper"

describe ArticlesController, :type => :controller do
  render_views

  context "show" do
    let(:article) { FactoryGirl.create(:article_with_events) }

    it "GET DOI" do
      get "/articles/info:doi/#{article.doi}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(article.doi)
    end

    it "GET pmid" do
      get "/articles/info:pmid/#{article.pmid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(article.pmid)
    end

    it "GET pmcid" do
      get "/articles/info:pmcid/PMC#{article.pmcid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(article.pmcid.to_s)
    end
  end

  context "errors" do
    it "redirects to the home page for an unknown article" do
      get "/articles/info:doi/x"
      expect(last_response.status).to eq(302)
      expect(last_response.body).to include("redirected")
    end

    it "redirects to the home page for an unknown path" do
      get "/x"
      expect(last_response.status).to eq(302)
      expect(last_response.body).to include("redirected")
    end
  end
end
