require 'rails_helper'

describe OembedController, :type => :controller do
  render_views

  let(:article) { FactoryGirl.create(:article_with_events) }
  let(:uri) { "/oembed?url=#{article_path(article)}" }

  context "discovery" do
    it "correct oembed link" do
      get article_path(article)
      expect(last_response.status).to eq(200)
      expect(last_response.body).to have_css(%Q(link[rel="alternate"][type="application/json+oembed"][title="Article oEmbed Profile"][href="#{uri}"]), visible: false)
      expect(Alert.count).to eq(0)
    end
  end

  context "show" do
    it "GET oembed" do
      get uri
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(article.title)
      expect(response["url"]).to eq(article.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed escaped" do
      get "http://#{ENV['SERVERNAME']}/oembed?url=maxwidth=474&maxheight=711&url=#{CGI.escape(article_url(article))}&format=json"
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(article.title)
      expect(response["url"]).to eq(article.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed JSON" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/json'
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(article.title)
      expect(response["url"]).to eq(article.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed XML" do
      get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
      expect(last_response.status).to eq(200)
      response = Hash.from_xml(last_response.body)
      response = response["oembed"]
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(article.title)
      expect(response["url"]).to eq(article.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end
  end

  context "errors" do
    it "Not found JSON" do
      get "/oembed?url=x", 'HTTP_ACCEPT' => 'application/json'
      expect(last_response.status).to eql(404)
      response = JSON.parse(last_response.body)
      expect(response).to eq("error" => "No article found.")
    end

    it "Not found XML" do
      get "/oembed?url=x", nil, 'HTTP_ACCEPT' => 'application/xml'
      expect(last_response.status).to eql(404)
      response = Hash.from_xml(last_response.body)
      expect(response).to eq("hash" => { "error" => "No article found." })
    end
  end
end
