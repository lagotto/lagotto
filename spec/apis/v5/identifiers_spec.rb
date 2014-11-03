require "rails_helper"

describe "/api/v5/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Article not found."} }

  context "index" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 50) }

    context "articles found via DOI" do
      before(:each) do
        article_list = articles.map { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=doi&info=summary&api_key=#{api_key}"
      end

      it "no format" do
        get @uri
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["doi"] == articles[0].doi
          expect(article["issued"]["date-parts"][0]).to eql([articles[0].year, articles[0].month, articles[0].day])
        end).to be true
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["doi"] == articles[0].doi
          expect(article["issued"]["date-parts"][0]).to eql([articles[0].year, articles[0].month, articles[0].day])
        end).to be true
      end
    end

    context "articles found via PMID" do
      before(:each) do
        article_list = articles.map { |article| "#{article.pmid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=pmid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["pmid"] == articles[0].pmid
        end).to be true
      end
    end

    context "articles found via PMCID" do
      before(:each) do
        article_list = articles.map { |article| "#{article.pmcid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=pmcid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["pmcid"] == "2568856" # articles[0].pmcid
        end).to be true
      end
    end

    context "articles found via Mendeley" do
      before(:each) do
        article_list = articles.map { |article| "#{article.mendeley_uuid}" }.join(",")
        @uri = "/api/v5/articles?ids=#{article_list}&type=mendeley_uuid&info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["mendeley_uuid"] == articles[0].mendeley_uuid
        end).to be true
      end
    end

    context "no identifiers" do
      before(:each) do
        article_list = articles.map { |article| "#{article.doi_escaped}" }.join(",")
        @uri = "/api/v5/articles?info=summary&api_key=#{api_key}"
      end

      it "JSON" do
        get @uri, nil, 'HTTP_ACCEPT' => 'application/json'
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |article|
          article["doi"] == articles[0].doi
          expect(article["issued"]["date-parts"][0]).to eql([articles[0].year, articles[0].month, articles[0].day])
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v5/articles?ids=xxx&info=summary&api_key=#{api_key}" }
      let(:nothing_found) { { "data" => [], "total" => 0, "total_pages" => 0, "page" => 0, "error" => nil } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
