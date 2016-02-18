require "rails_helper"

describe WorksController, :type => :controller do
  render_views

  let(:work) { FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0043007", doi: "10.1371/journal.pone.0043007", canonical_url: "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0043007") }

  context "show" do
    it "GET pid" do
      get "/works/#{work.pid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.pid)
    end

    it "GET doi" do
      get "/works/doi:#{work.doi}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.doi)
    end

    it "GET pmid" do
      get "/works/pmid:#{work.pmid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.pmid)
    end

    it "GET pmcid" do
      get "/works/pmcid:PMC#{work.pmcid}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.pmcid.to_s)
    end

    it "GET canonical_url" do
      get "/works/#{work.canonical_url}"
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include(work.canonical_url)
    end
  end

  context "RSS" do
    it "GET" do
      related_work = FactoryGirl.create(:work, pid: "http://doi.org/10.1016/j.foodqual.2015.03.018", doi: "10.1016/j.foodqual.2015.03.018", title: "Influence of the glassware on the perception of alcoholic drinks")
      relation = FactoryGirl.create(:relation, work: work, related_work: related_work)
      get "/rss/works/doi:#{work.doi}"
      expect(last_response.status).to eq(200)

      response = Hash.from_xml(last_response.body)
      item = response["rss"]["channel"]["item"]
      expect(item["link"]).to eq("http://doi.org/10.1016/j.foodqual.2015.03.018")
    end
  end

  context "errors" do
    it "redirects to the home page for an unknown work" do
      get "/works/doi:x"
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
