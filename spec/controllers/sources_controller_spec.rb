require "rails_helper"

describe SourcesController, :type => :controller do
  render_views

  context "show" do
    it "raises not found error for an unknown source" do
      get source_path("x")
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include("The page you are looking for doesn&#39;t exist.")
    end
  end

  context "RSS" do
    let!(:works) { FactoryGirl.create_list(:work_for_feed, 2) }
    let(:source) { FactoryGirl.create(:source) }

    it "returns an RSS feed for most-cited (7 days)" do
      get rss_source_path(source, days: 7)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.title}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited (30 days)" do
      get rss_source_path(source, days: 30)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.title}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited (12 months)" do
      get rss_source_path(source, months: 12)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.title}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns an RSS feed for most-cited" do
      get rss_source_path(source)
      expect(last_response.status).to eq(200)
      expect(last_response).to render_template("sources/show")
      expect(last_response.content_type).to eq("application/rss+xml; charset=utf-8")

      response = Hash.from_xml(last_response.body)
      response = response["rss"]
      expect(response["version"]).to eq("2.0")
      expect(response["channel"]["title"]).to eq("Lagotto: most-cited works in #{source.title}")
      expect(Addressable::URI.parse(response["channel"]["link"]).path).to eq(source_path(source))
      expect(response["channel"]["item"]).not_to be_nil
    end

    it "returns a proper RSS error for an unknown source" do
      get rss_source_path("x")
      expect(last_response.status).to eq(404)
      response = Hash.from_xml(last_response.body)
      response = response["rss"]["channel"]
      expect(response["title"]).to eq("Lagotto: source not found")
      expect(response["link"]).to eq("http://example.org/")
    end
  end
end
