require "rails_helper"

describe "/api/v3/articles" do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Article not found."} }

  context "index" do
    let(:articles) { FactoryGirl.create_list(:article_with_events, 50) }

    context "articles found via DOI" do
      let(:article_list) { articles.map { |article| "#{article.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v3/articles?ids=#{article_list}&type=doi&api_key=#{api_key}" }

      it "no format" do
        get uri
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end).to be true
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end).to be true
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        expect(response.length).to eql(50)
        expect(response.any? do |article|
          article["doi"] == articles[0].doi
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end).to be true
      end
    end

    context "articles found via PMID" do
      let(:article_list) { articles.map { |article| "#{article.pmid}" }.join(",") }
      let(:uri) { "/api/v3/articles?ids=#{article_list}&type=pmid&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |article|
          article["pmid"] == articles[0].pmid
        end).to be true
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        expect(response.length).to eql(50)
        expect(response.any? do |article|
          article["pmid"] == articles[0].pmid
          article["publication_date"] == articles[0].published_on.to_time.utc.iso8601
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v3/articles?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_json)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_xml)
      end
    end

  end

  context "show" do

    context "DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{api_key}" }

      it "no format" do
        get uri
        expect(last_response.status).to eql(200)

        response_article = JSON.parse(last_response.body)[0]
        response_source = response_article["sources"][0]
        expect(response_article["doi"]).to eql(article.doi)
        expect(response_article["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["events"]).to be_nil
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(article.doi)
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["events"]).to be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        expect(response["doi"]).not_to be_nil
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"].to_i).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["events"]).to be_nil
      end

    end

    context "PMID" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:pmid/#{article.pmid}?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        expect(response["pmid"]).to eql(article.pmid.to_s)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        expect(response["doi"]).not_to be_nil
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response["pmid"]).to eql(article.pmid.to_s)
      end

    end

    context "PMCID" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:pmcid/PMC#{article.pmcid}?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        expect(response["pmcid"]).to eql(article.pmcid.to_s)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        expect(response["doi"]).not_to be_nil
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response["pmcid"]).to eql(article.pmcid.to_s)
      end

    end

    context "Mendeley" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:mendeley/#{article.mendeley_uuid}?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response_article = JSON.parse(last_response.body)[0]
        expect(response_article["mendeley"]).to eql(article.mendeley_uuid)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        expect(response["doi"]).not_to be_nil
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response["mendeley"]).to eql(article.mendeley_uuid)
      end

    end

    context "wrong DOI" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}xx?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_json)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_xml)
      end
    end

    context "article not found when using format as file extension" do
      let(:article) { FactoryGirl.create(:article_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}xx" }

      it "JSON" do
        get "#{uri}.json?api_key=#{api_key}", nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_json)
      end

      it "XML" do
        get "#{uri}.xml?api_key=#{api_key}", nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_xml)
      end
    end

  end
end
