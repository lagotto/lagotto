require "rails_helper"

describe "/api/v6/works", :type => :api do
  let(:headers) { { "HTTP_ACCEPT" => "application/vnd.lagotto+json; version=6" } }
  let(:jsonp_headers) { { "HTTP_ACCEPT" => "application/javascript" } }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_events, 10) }

    context "works found via pid" do
      before(:each) do
        work_list = works.map { |work| "#{work.pid}" }.join(",")
        @uri = "/api/works?ids=#{work_list}"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["doi"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=doi"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["DOI"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "works found via PMID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmid}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=pmid"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["PMID"] == works[0].pmid
        end).to be true
      end
    end

    context "works found via PMCID" do
      before(:each) do
        work_list = works.map { |work| "#{work.pmcid}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=pmcid"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["PMCID"] == works[0].pmcid
        end).to be true
      end
    end

    context "works found via wos" do
      before(:each) do
        work_list = works.map { |work| "#{work.wos}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=wos"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["wos"] == works[0].wos
        end).to be true
      end
    end

    context "works found via scp" do
      before(:each) do
        work_list = works.map { |work| "#{work.scp}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=scp"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["scp"] == works[0].scp
        end).to be true
      end
    end

    context "works found via URL" do
      before(:each) do
        work_list = works.map { |work| "#{work.canonical_url}" }.join(",")
        @uri = "/api/works?ids=#{work_list}&type=url"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["URL"] == works[0].canonical_url
        end).to be true
      end
    end

    context "no identifiers" do
      before(:each) do
        work_list = works.map { |work| "#{work.doi_escaped}" }.join(",")
        @uri = "/api/works"
      end

      it "JSON" do
        get @uri, nil, headers
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["DOI"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "by publisher" do
      let(:publisher) { FactoryGirl.create(:publisher) }
      let(:works) { FactoryGirl.create_list(:work_with_events, 10, publisher_id: publisher.member_id) }
      let!(:work_list) { works.map { |work| "#{work.doi_escaped}" }.join(",") }
      let(:uri) { "/api/works?publisher_id=#{publisher.member_id}" }

      it "JSON" do
        get uri, nil, headers
        work = works.first
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["DOI"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end

      it "JSONP" do
        get "#{uri}&callback=_func", nil, jsonp_headers
        work = works.first
        expect(last_response.status).to eql(200)

        # remove jsonp wrapper
        response = JSON.parse(last_response.body[6...-1])
        data = response["works"]
        expect(data.length).to eq(10)
        expect(data.any? do |work|
          work["DOI"] == works[0].doi
          expect(work["issued"]["date-parts"][0]).to eql([works[0].year, works[0].month, works[0].day])
        end).to be true
      end
    end

    context "no records found" do
      let(:uri) { "/api/works?ids=xxx" }
      let(:nothing_found) { { "meta" => { "status" => "ok", "message-type" => "work-list", "message-version" => "6.0.0", "total" => 0, "total_pages" => 1, "page" => 1 }, "works" => [] } }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
