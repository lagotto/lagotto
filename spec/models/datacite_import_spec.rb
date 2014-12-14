require 'rails_helper'

describe DataciteImport, :type => :model do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = DataciteImport.new
      body = File.read(fixture_path + 'datacite_import_no_rows.json')
      stub = stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => body)
      expect(import.total_results).to eq(2636)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_update_date" do
      import = DataciteImport.new(from_update_date: "2013-09-01")
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-01T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_update_date" do
      import = DataciteImport.new(until_update_date: "2013-09-05")
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with member_id" do
      import = DataciteImport.new(member: "340")
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=datacentre_symbol:340&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with type" do
      import = DataciteImport.new(type: "Dataset")
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=resourceTypeGeneral:Dataset&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=250&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = DataciteImport.new
      url = "http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=250&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data default no data" do
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import_nil.json")
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data access denied error" do
      import = DataciteImport.new
      body = File.read(fixture_path + "access_denied.txt")
      error = "the server responded with status 401 for http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true"
      stub = stub_request(:get, import.query_url).to_return(:body => body, :status => 401)
      response = import.get_data
      expect(response).to eq(error: error, status: 401)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPUnauthorized")
      expect(alert.message).to eq(error)
      expect(alert.status).to eq(401)
    end

    it "should get_data timeout error" do
      import = DataciteImport.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre%2Cdatacentre_symbol%2Cprefix%2CrelatedIdentifier%2Cupdated&q=%2A%3A%2A&rows=1000&start=0&wt=json&fq=updated:[2013-09-04T00:00:00Z%20TO%202013-09-05T23:59:59Z]&fq=publicationYear:[1650%20TO%202013]&fq=has_metadata:true&fq=is_active:true", status: 408)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
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
      expect(response.length).to eq(10)

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
      expect(response.length).to eq(10)
      expect(response).to eq((1..10).to_a)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = DataciteImport.new
      body = File.read(fixture_path + "datacite_import.json")
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.length).to eq(10)
      expect(response).to eq((1..10).to_a)
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
      expect(response.compact).to eq((1..9).to_a)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.5061/DRYAD.47SD5.")
      expect(alert.target_url).to eq("http://api.crossref.org/works/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
