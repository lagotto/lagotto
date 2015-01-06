require 'rails_helper'

describe PlosImport, type: :model, vcr: true do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = PlosImport.new
      expect(import.total_results).to eq(394)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = PlosImport.new
      url = "http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_pub_date" do
      import = PlosImport.new(from_pub_date: "2013-09-01")
      url = "http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-01T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_pub_date" do
      import = PlosImport.new(until_pub_date: "2013-09-04")
      url = "http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-04T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = PlosImport.new
      url = "http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=250&wt=json"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = PlosImport.new
      url = "http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=250&start=0&wt=json"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = PlosImport.new
      response = import.get_data
      expect(response["response"]["numFound"]).to eq(394)
      work = response["response"]["docs"][1]
      expect(work["id"]).to eq("10.1371/annotation/c8463645-79f3-4d9b-bc55-d5d53e43a9ba")
      expect(work["title_display"]).to eq("Correction: Duplication of <i>C7orf58</i>, <i>WNT16</i> and <i>FAM3C</i> in an Obese Female with a t(7;22)(q32.1;q11.2) Chromosomal Translocation and Clinical Features Resembling Coffin-Siris Syndrome")
    end

    it "should get_data default no data" do
      import = PlosImport.new(from_pub_date: "2013-09-01", until_pub_date: "2013-09-01")
      response = import.get_data
      expect(response).to eq("response"=>{"numFound"=>0, "start"=>0, "docs"=>[]})
    end

    it "should get_data timeout error" do
      import = PlosImport.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display&fq=%2Bpublication_date%3A%5B2013-09-04T00%3A00%3A00Z+TO+2013-09-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json", status: 408)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(29)

      work = response.first
      expect(work[:doi]).to eq("10.1371/journal.pone.0075114")
      expect(work[:title]).to eq("Fine Tuning of Spatial Arrangement of Enzymes in a PCNA-Mediated Multienzyme Complex Using a Rigid Poly-L-Proline Linker")
      expect(work[:year]).to eq(2013)
      expect(work[:month]).to eq(9)
      expect(work[:day]).to eq(5)
      expect(work[:publisher_id]).to eq(340)
    end

    it "should parse_data missing date" do
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["publication_date"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(29)

      work = response[5]
      expect(work[:doi]).to eq("10.1371/journal.pone.0074903")
      expect(work[:title]).to eq("Sexual Behavior and Condom Use among Seasonal Dalit Migrant Laborers to India from Far West, Nepal: A Qualitative Study")
      expect(work[:year]).to be_nil
      expect(work[:month]).to be_nil
      expect(work[:day]).to be_nil
      expect(work[:publisher_id]).to eq(340)
    end

    it "should parse_data missing title" do
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["title_display"] = nil
      response = import.parse_data(result)
      expect(response.length).to eq(29)

      work = response[5]
      expect(work[:doi]).to eq("10.1371/journal.pone.0074903")
      expect(work[:title]).to be_nil
    end
  end

  context "import_data" do
    it "should import_data" do
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(29)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(29)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = PlosImport.new
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(28)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.1371/journal.pone.0075114.")
      expect(alert.target_url).to eq("http://dx.doi.org/10.1371/journal.pone.0075114")
    end
  end
end
