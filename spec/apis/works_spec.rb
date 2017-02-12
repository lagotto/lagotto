require "rails_helper"

describe "/works", :type => :api do
  let(:headers) { { "HTTP_ACCEPT" => "application/json" } }
  let(:jsonp_headers) { { "HTTP_ACCEPT" => "application/javascript" } }

  context "index" do
    let(:works) { FactoryGirl.create_list(:work_with_ids, 10, year: 2015, month: 4, day: 4) }

    context "works found via pid" do
      before(:each) do
        work_list = works.map { |work| work.pid }.join(",")
        @uri = "/works?ids=#{work_list}"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via DOI" do
      before(:each) do
        work_list = works.map { |work| work.doi_escaped }.join(",")
        @uri = "/works?ids=#{work_list}&type=doi"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via PMID" do
      before(:each) do
        work_list = works.map { |work| work.pmid }.join(",")
        @uri = "/works?ids=#{work_list}&type=pmid"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via PMCID" do
      before(:each) do
        work_list = works.map { |work| work.pmcid }.join(",")
        @uri = "/works?ids=#{work_list}&type=pmcid"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via wos" do
      before(:each) do
        work_list = works.map { |work| work.wos }.join(",")
        @uri = "/works?ids=#{work_list}&type=wos"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via scp" do
      before(:each) do
        work_list = works.map { |work| work.scp }.join(",")
        @uri = "/works?ids=#{work_list}&type=scp"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "works found via URL" do
      before(:each) do
        work_list = works.map { |work| work.canonical_url_escaped }.join(",")
        @uri = "/works?ids=#{work_list}&type=url"
      end

      it "JSON" do
        get @uri, nil, headers
        expect(last_response.status).to eq(200)

        response = JSON.parse(last_response.body)
        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "no identifiers" do
      before(:each) do
        work_list = works.map { |work| work.doi_escaped }.join(",")
        @uri = "/works"
      end

      it "JSON" do
        get @uri, nil, headers
        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)

        data = response["data"]
        expect(data.length).to eq(10)
        work = data.first
        expect(work.fetch("attributes", {}).fetch("title", nil)).to eq("Defrosting the Digital Library: Bibliographic Tools for the Next Generation Web")
        expect(work.fetch("attributes", {}).fetch("published", nil)).to eq("2015-04-04")
      end
    end

    context "no records found" do
      let(:uri) { "/works?ids=xxx" }
      let(:nothing_found) { { "data" => [], "links" => {}, "meta" => { "total" => 0, "total-pages" => 0, "page" => 1 } } }

      it "JSON" do
        get uri, nil, headers
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq(nothing_found.to_json)
      end
    end
  end
end
