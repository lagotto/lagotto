require 'rails_helper'

describe DataciteImport, type: :model, vcr: true do

  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = DataciteImport.new
      expect(import.total_results).to eq(5423365)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_update_date" do
      import = DataciteImport.new(from_update_date: "2013-09-01")
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-01T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_update_date" do
      import = DataciteImport.new(until_update_date: "2013-09-05")
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with member_id" do
      import = DataciteImport.new(member: "CDL.DRYAD")
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=datacentre_symbol%3ACDL.DRYAD&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with type" do
      import = DataciteImport.new(type: "Dataset")
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=resourceTypeGeneral%3ADataset&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?q=*%3A*&start=250&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?q=*%3A*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = DataciteImport.new
      response = import.get_data
      expect(response["response"]["numFound"]).to eq(5423365)
      work = response["response"]["docs"].first
      expect(work["doi"]).to eq("10.5517/CCPW8WP")
      expect(work["title"]).to eq(["CCDC 651833: Experimental Crystal Structure Determination"])
    end

    it "should get_data default no data" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import_nil.json")
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data timeout error" do
      import = DataciteImport.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D&fq=publicationYear%3A%5B1650+TO+2013%5D&fq=has_metadata%3Atrue&fq=is_active%3Atrue&wt=json", status: 408)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeout")
      expect(alert.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response.first
      expect(work[:doi]).to eq("10.5061/DRYAD.47SD5")
      expect(work[:title]).to eq("Data from: A call for more transparent reporting of error rates: the quality of AFLP data in ecological and evolutionary research")
      expect(work[:year]).to eq(2012)
      expect(work[:publisher_id]).to eq(16041)
    end

    it "should parse_data incomplete date" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.5061/DRYAD.NK151/2")
      expect(work[:title]).to eq("Presence/absence SNPs matrix")
      expect(work[:year]).to eq(2013)
      expect(work[:publisher_id]).to eq(16041)
    end

    it "should parse_data missing title" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      result["response"]["docs"][5]["title"] = []
      response = import.parse_data(result)
      expect(response.compact.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.5061/DRYAD.NK151/2")
      expect(work[:title]).to be_nil
    end
  end

  context "import_data" do
    it "should import_data" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(10)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(10)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(9)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.5061/DRYAD.47SD5.")
      expect(alert.target_url).to eq("http://doi.org/10.5061/DRYAD.47SD5")
    end
  end
end
