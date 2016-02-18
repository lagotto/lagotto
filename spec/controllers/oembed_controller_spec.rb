require 'rails_helper'

describe OembedController, :type => :controller do
  render_views

  let(:work) { FactoryGirl.create(:work, :with_events) }
  let(:uri) { "/oembed?url=#{work_path(work)}" }

  context "discovery" do
    it "correct oembed link" do
      get work_path(work)
      expect(last_response.status).to eq(200)
      expect(last_response.body).to have_css(%Q(link[rel="alternate"][type="application/json+oembed"][title="Work oEmbed Profile"][href="#{uri}"]), visible: false)
      expect(Notification.count).to eq(0)
    end
  end

  context "show" do
    it "GET oembed" do
      get uri
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed escaped" do
      get "http://#{ENV['SERVERNAME']}/oembed?url=maxwidth=474&maxheight=711&url=#{work.pid_escaped}&format=json"
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed JSON" do
      get "#{uri}&format=json"
      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end

    it "GET oembed XML" do
      get "#{uri}&format=xml"
      expect(last_response.status).to eq(200)
      response = Hash.from_xml(last_response.body)
      response = response["oembed"]
      expect(response["type"]).to eq("rich")
      expect(response["title"]).to eq(work.title)
      expect(response["url"]).to eq(work.doi_as_url)
      expect(response["html"]).to include("<blockquote class=\"alm\">")
    end
  end

  context "errors" do
    it "Not found JSON" do
      get "/oembed?url=x"
      expect(last_response.status).to eql(404)
      response = JSON.parse(last_response.body)
      expect(response).to eq("error" => "No work found.")
    end

    it "Not found XML" do
      get "/oembed?url=x&format=xml"
      expect(last_response.status).to eql(404)
      response = Hash.from_xml(last_response.body)
      expect(response).to eq("error" => "No work found.")
    end
  end
end
