require 'spec_helper'

describe OembedController do
  render_views

  context "show" do
    let(:article) { FactoryGirl.create(:article_with_events) }
    let(:uri) { "/oembed?url=#{article_path(article)}" }

    it "GET oembed" do
      get uri
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm well well-small\">")
    end

    it "GET oembed JSON" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm well well-small\">")
    end

    it "GET oembed XML" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
      last_response.status.should == 200
      response = Hash.from_xml(last_response.body)
      response = response["oembed"]
      response["type"].should eq("rich")
      response["title"].should eq(article.title)
      response["url"].should eq(article.doi_as_url)
      response["html"].should include("<blockquote class=\"alm well well-small\">")
    end
  end

  context "errors" do
    it "RoutingError error" do
      expect { get "/oembed?url=x" }.to raise_error(ActionController::RoutingError)
      Alert.count.should == 0
    end
  end
end
