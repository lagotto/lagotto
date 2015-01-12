require 'rails_helper'

describe DataoneImport, type: :model, vcr: true do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2014, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = DataoneImport.new
      expect(import.total_results).to eq(61)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = DataoneImport.new
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_update_date" do
      import = DataoneImport.new(from_update_date: "2014-09-01")
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B2014-09-01T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-01T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_update_date" do
      import = DataoneImport.new(until_update_date: "2014-09-05")
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_pub_date" do
      import = DataoneImport.new(from_pub_date: "2014-09-01")
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_pub_date" do
      import = DataoneImport.new(until_pub_date: "2014-09-04")
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-04T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = DataoneImport.new
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=250&wt=json"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = DataoneImport.new
      url = "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=250&start=0&wt=json"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = DataoneImport.new
      response = import.get_data
      expect(response["response"]["numFound"]).to eq(61)
      work = response["response"]["docs"][1]
      expect(work["id"]).to eq("http://dx.doi.org/10.5061/dryad.0r7g4?ver=2014-09-03T13:03:52.788-04:00")
      expect(work["title"]).to eq("Data from: Individual genetic diversity and probability of infection by avian malaria parasites in blue tits (Cyanistes caeruleus)")
    end

    it "should get_data default no data" do
      import = DataoneImport.new(from_update_date: "2014-09-07", until_update_date: "2014-09-07")
      response = import.get_data
      expect(response).to eq("responseHeader"=>{"status"=>0, "QTime"=>7, "params"=>{"fl"=>"id,title,author,datePublished,authoritativeMN,dateModified", "start"=>"0", "q"=>"datePublished:[2014-09-07T00:00:00Z TO 2014-09-05T23:59:59Z]+dateModified:[2014-09-07T00:00:00Z TO 2014-09-07T23:59:59Z]+formatType:METADATA", "wt"=>"json", "rows"=>"1000"}}, "response"=>{"numFound"=>0, "start"=>0, "docs"=>[]})
    end

    it "should get_data timeout error" do
      import = DataoneImport.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      expect(response).to eq(error: "the server responded with status 408 for https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=datePublished%3A%5B1914-09-05T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BdateModified%3A%5B2014-09-04T00%3A00%3A00Z+TO+2014-09-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json", status: 408)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(61)

      work = response.first
      expect(work[:doi]).to eq("10.5061/dryad.tm8k3")
      expect(work[:title]).to eq("Data from: Evolutionary neutrality of mtDNA introgression: evidence from complete mitogenome analysis in roe deer")
      expect(work[:year]).to eq(2014)
      expect(work[:month]).to eq(9)
      expect(work[:day]).to eq(3)
      expect(work[:publisher_id]).to eq(39875)
    end

    it "should parse_data missing date" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["datePublished"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(61)

      work = response[5]
      expect(work[:doi]).to eq("10.5061/dryad.1v8kj/1")
      expect(work[:title]).to eq("Scleral ring and orbit morphology")
      expect(work[:year]).to be_nil
      expect(work[:month]).to be_nil
      expect(work[:day]).to be_nil
      expect(work[:publisher_id]).to eq(39875)
    end

    it "should parse_data missing title" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["title"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(61)

      work = response[5]
      expect(work[:doi]).to eq("10.5061/dryad.1v8kj/1")
      expect(work[:title]).to be_nil
    end

    it "should parse_data ark identifier" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["id"] = "ark:/13030/m5dz07w9/2/cadwsap-s4010832-002.xml"
      response = import.parse_data(result)
      expect(response.length).to eq(61)

      work = response[5]
      expect(work[:doi]).to be_nil
      expect(work[:ark]).to eq("ark:/13030/m5dz07w9")
      expect(work[:title]).to eq("Scleral ring and orbit morphology")
    end

    it "should raise error on unknown identifier" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["id"] = "knb-lter-arc.10353.1"
      response = import.parse_data(result)
      expect(response.length).to eq(61)

      work = response[5]
      expect(work[:doi]).to be_nil
      expect(work[:ark]).to be_nil
      expect(work[:title]).to eq("Scleral ring and orbit morphology")

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveModel::MissingAttributeError")
      expect(alert.message).to eq("No known identifier found in knb-lter-arc.10353.1")
    end
  end

  context "import_data" do
    it "should import_data" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(61)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.5061/dryad.1v8kj/1")
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(61)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = DataoneImport.new
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(60)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.5061/dryad.tm8k3.")
      expect(alert.target_url).to eq("http://dx.doi.org/10.5061/dryad.tm8k3")
    end
  end
end
