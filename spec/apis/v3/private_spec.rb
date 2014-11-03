require "rails_helper"

describe "/api/v3/articles" do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(article.doi)
        expect(response["publication_date"]).to eq(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("citations")
        expect(response_source["metrics"]["shares"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("comments")
        expect(response_source["metrics"]).to include("groups")
        expect(response_source["metrics"]).to include("html")
        expect(response_source["metrics"]).to include("likes")
        expect(response_source["metrics"]).to include("pdf")
        expect(response_source["events"]).to be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        expect(response["doi"]).to eql(article.doi)
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"].to_i).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]["citations"]).to be_nil
        expect(response_source["metrics"]["shares"].to_i).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]["groups"]).to be_nil
        expect(response_source["metrics"]["html"]).to be_nil
        expect(response_source["metrics"]["likes"]).to be_nil
        expect(response_source["metrics"]["pdf"]).to be_nil
        expect(response_source["events"]).to be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)[0]
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(article.doi)
        expect(response["publication_date"]).to eq(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("citations")
        expect(response_source["metrics"]["shares"]).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("comments")
        expect(response_source["metrics"]).to include("groups")
        expect(response_source["metrics"]).to include("html")
        expect(response_source["metrics"]).to include("likes")
        expect(response_source["metrics"]).to include("pdf")
        expect(response_source["events"]).to be_nil
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(200)

        response = Hash.from_xml(last_response.body)
        response = response["articles"]["article"]
        response_source = response["sources"]["source"]
        expect(response["doi"]).to eql(article.doi)
        expect(response["publication_date"]).to eql(article.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"].to_i).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]["citations"]).to be_nil
        expect(response_source["metrics"]["shares"].to_i).to eq(article.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]["groups"]).to be_nil
        expect(response_source["metrics"]["html"]).to be_nil
        expect(response_source["metrics"]["likes"]).to be_nil
        expect(response_source["metrics"]["pdf"]).to be_nil
        expect(response_source["events"]).to be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:article) { FactoryGirl.create(:article_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{article.doi}?api_key=#{user.api_key}" }
      let(:error) { { "error"=>"Article not found." } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end

      it "XML" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/xml'
        expect(last_response.status).to eql(404)

        response = Hash.from_xml(last_response.body)["hash"]
        expect(response).to eq (error)
      end
    end
  end
end
