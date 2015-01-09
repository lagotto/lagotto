require "rails_helper"

describe "/api/v3/articles", :type => :api do

  context "private source" do
    context "as admin user" do
      let(:user) { FactoryGirl.create(:admin_user) }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eq(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("citations")
        expect(response_source["metrics"]["shares"]).to eq(work.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("comments")
        expect(response_source["metrics"]).to include("groups")
        expect(response_source["metrics"]).to include("html")
        expect(response_source["metrics"]).to include("likes")
        expect(response_source["metrics"]).to include("pdf")
        expect(response_source["events"]).to be_nil
      end
    end

    context "as staff user" do
      let(:user) { FactoryGirl.create(:user, :role => "staff") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}?api_key=#{user.api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eq(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("citations")
        expect(response_source["metrics"]["shares"]).to eq(work.retrieval_statuses.first.event_count)
        expect(response_source["metrics"]).to include("comments")
        expect(response_source["metrics"]).to include("groups")
        expect(response_source["metrics"]).to include("html")
        expect(response_source["metrics"]).to include("likes")
        expect(response_source["metrics"]).to include("pdf")
        expect(response_source["events"]).to be_nil
      end
    end

    context "as regular user" do
      let(:user) { FactoryGirl.create(:user, :role => "user") }
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}?api_key=#{user.api_key}" }
      let(:error) { { "error"=>"Article not found." } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end

    context "without API key" do
      let(:work) { FactoryGirl.create(:work_with_private_citations) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}" }
      let(:error) { { "error"=>"Article not found." } }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)

        response = JSON.parse(last_response.body)
        expect(response).to eq (error)
      end
    end
  end
end
