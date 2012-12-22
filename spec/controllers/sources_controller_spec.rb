require 'spec_helper'

describe SourcesController do
  render_views
  
  context "RSS" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 10) }
    let(:source) { FactoryGirl.create(:source) }

    it "returns an RSS feed for most-cited (7 days)" do
      get source_path(source, format: "rss")
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
    end
  
    it "returns an RSS feed for most-cited (30 days)" do
      get source_path(source, format: "rss")
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
    end
  
    it "returns an RSS feed for most-cited (12 months)" do
      get source_path(source, format: "rss")
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Hash.from_xml(last_response.body)["rss"]
      response["version"].should eq("2.0")
      response["channel"]["title"].should eq(nil)
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response_articles = Nokogiri::XML(last_response.body).css("item")
      response_articles.length.should eql(10)
    end
  
    it "returns an RSS feed for most-cited" do
      get source_path(source, format: "rss")
      last_response.status.should eql(200)
      last_response.should render_template("sources/show")
      last_response.content_type.should eq("application/rss+xml; charset=utf-8")
      
      response = Hash.from_xml(last_response.body)["rss"]
      response["version"].should eq("2.0")
      response["channel"]["title"].should eq(nil)
      URI.parse(response["channel"]["link"]).path.should eq(source_path(source))
      response_articles = Nokogiri::XML(last_response.body).css("item")
      response_articles.length.should eql(10)
    end
  end

end