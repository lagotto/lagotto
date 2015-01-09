require "rails_helper"

describe WorksController, :type => :controller do
  render_views

  context "show" do
    let(:work) { FactoryGirl.create(:work_with_events, canonical_url: "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0043007") }

    it "GET doi" do
      get "/works/doi/#{work.doi}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.doi)
    end

    it "GET pmid" do
      get "/works/pmid/#{work.pmid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.pmid)
    end

    it "GET pmcid" do
      get "/works/pmcid/PMC#{work.pmcid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.pmcid.to_s)
    end

    it "GET canonical_url" do
      get "/works/url/#{work.canonical_url}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.canonical_url)
    end
  end

  context "errors" do
    it "redirects to the home page for an unknown work" do
      get "/works/doi/x"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include("The page you are looking for doesn&#39;t exist.")
    end

    it "redirects to the home page for an unknown path" do
      get "/x"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include("The page you are looking for doesn&#39;t exist.")
    end
  end
end
