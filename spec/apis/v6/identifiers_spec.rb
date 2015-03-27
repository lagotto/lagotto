require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:user) { FactoryGirl.create(:user) }
  let(:api_key) { user.authentication_token }
  let(:error) { { "error" => "Article not found."} }
  let(:headers) do
    { "HTTP_ACCEPT" => "application/json",
      "Authorization" => "Token token=#{user.api_key}" }
  end

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 50) }

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=doi&info=summary"
      end

      it "no format" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "works found via PMID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmid}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=pmid&info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["pmid"] == works[0].pmid
        end).to be true
      end
    end

    context "works found via PMCID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmcid}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=pmcid&info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["pmcid"] == works[0].pmcid
        end).to be true
      end
    end

    context "works found via wos" do
      before(:each) do
        work_list = works.map { |work| "#{work.wos}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=wos&info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["wos"] == works[0].wos
        end).to be true
      end
    end

    context "works found via scp" do
      before(:each) do
        work_list = works.map { |work| "#{work.scp}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=scp&info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["scp"] == works[0].scp
        end).to be true
      end
    end

    context "works found via URL" do
      before(:each) do
        work_list = works.map { |work| "#{work.canonical_url}" }.join(",")
        @uri = "/api/v6/works?ids=#{work_list}&type=url&info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["canonical_url"] == works[0].canonical_url
        end).to be true
      end
    end

    context "no identifiers" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/v6/works?info=summary"
      end

      it "JSON" do
        get @uri, nil, headers
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        data = response["data"]
        expect(data.length).to eq(50)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/v6/works?ids=xxx&info=summary" }
      let(:nothing_found) { { "meta" => { "total" => 0, "total_pages" => 0, "page" => 0 }, "works" => [] } }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
