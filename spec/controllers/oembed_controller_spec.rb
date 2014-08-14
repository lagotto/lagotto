require 'spec_helper'

describe OembedController do
  render_views

  let(:article) { FactoryGirl.create(:article_with_events) }
  let(:uri) { "http://#{CONFIG[:public_server]}/oembed?url=#{article_path(article)}" }

  context "discovery" do
    it "correct oembed link" do
      get article_path(article)
      last_response.status.should == 200
      last_response.body.should have_css(%Q(link[rel="alternate"][type="application/json+oembed"][title="Article oEmbed Profile"][href="#{uri}"]), visible: false)
      Alert.count.should == 0
    end
  end

  context "show" do
    it "GET oembed" do
      get uri
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm\">")
    end

    it "GET oembed escaped" do
      get "http://#{CONFIG[:public_server]}/oembed?url=maxwidth=474&maxheight=711&url=#{CGI.escape(article_url(article))}&format=json"
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm\">")
    end

    it "GET oembed JSON" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm\">")
    end

    it "GET oembed XML" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
      last_response.status.should == 200
      response = Hash.from_xml(last_response.body)
      response = response["oembed"]
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm\">")
    end
  end

  context "errors" do
    it "RoutingError error" do
      expect { get "/oembed?url=x" }.to raise_error(ActionController::RoutingError)
      Alert.count.should == 0
    end
  end
end
