require "rails_helper"

describe "/api/v3/articles", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Article not found."} }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 50) }

    context "works found via DOI" do
      let(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "/api/v3/articles?ids=#{work_list}&type=doi&api_key=#{api_key}" }

      it "no format" do
        get uri
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |work|
          work["doi"] == works[0].doi
          work["publication_date"] == works[0].published_on.to_time.utc.iso8601
        end).to be true
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |work|
          work["doi"] == works[0].doi
          work["publication_date"] == works[0].published_on.to_time.utc.iso8601
        end).to be true
      end
    end

    context "works found via PMID" do
      let(:work_list) { works.map { |work| "#{work.pmid}" }.join(",") }
      let(:uri) { "/api/v3/articles?ids=#{work_list}&type=pmid&api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response.length).to eql(50)
        expect(response.any? do |work|
          work["pmid"] == works[0].pmid
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
    end
  end

  context "show" do

    context "DOI" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}?api_key=#{api_key}" }

      it "no format" do
        get uri
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.events.first.total)
        expect(response_source["events"]).to be_nil
      end

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        response_source = response["sources"][0]
        expect(response["doi"]).to eql(work.doi)
        expect(response["publication_date"]).to eql(work.published_on.to_time.utc.iso8601)
        expect(response_source["metrics"]["total"]).to eq(work.events.first.total)
        expect(response_source["events"]).to be_nil
      end
    end

    context "PMID" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles/pmid/#{work.pmid}?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response["pmid"]).to eql(work.pmid.to_s)
      end
    end

    context "PMCID" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles/pmcid/PMC#{work.pmcid}?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(200)

        response = JSON.parse(last_response.body)
        expect(response["pmcid"]).to eql(work.pmcid.to_s)
      end
    end

    context "wrong DOI" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}xx?api_key=#{api_key}" }

      it "JSON" do
        get uri, nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_json)
      end
    end

    context "work not found when using format as file extension" do
      let(:work) { FactoryGirl.create(:work_with_events) }
      let(:uri) { "/api/v3/articles/info:doi/#{work.doi}xx" }

      it "JSON" do
        get "#{uri}.json?api_key=#{api_key}", nil, 'HTTP_ACCEPT' => 'application/json'
        expect(last_response.status).to eql(404)
        expect(last_response.body).to eq(error.to_json)
      end
    end
  end
end
