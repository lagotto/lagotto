require 'rails_helper'

describe CrossrefImport, type: :model, vcr: true do

  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import_no_rows.json')
      stub = stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => body)
      expect(import.total_results).to eq(22993)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = CrossrefImport.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_update_date" do
      import = CrossrefImport.new(from_update_date: "2013-09-01")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-01%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_update_date" do
      import = CrossrefImport.new(until_update_date: "2013-09-05")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with member_id" do
      import = CrossrefImport.new(member: "340,4374")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Cmember%3A340%2Cmember%3A4374&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with type" do
      import = CrossrefImport.new(type: 'book-entry')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Ctype%3Abook-entry&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with issn" do
      import = CrossrefImport.new(issn: '1545-7885')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Cissn%3A1545-7885&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with sample" do
      import = CrossrefImport.new(sample: 100)
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&sample=100"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = CrossrefImport.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=250&rows=1000"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = CrossrefImport.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=250"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = CrossrefImport.new
      response = import.get_data
      expect(response["message"]["total-results"]).to eq(102128)
      item = response["message"]["items"].first
      expect(item["DOI"]).to eq("10.3138/9781442618077_8")
    end

    it "should get_data default no data" do
      import = CrossrefImport.new(type: "standard-series")
      response = import.get_data
      expect(response["message"]["total-results"]).to eq(0)
    end

    it "should get_data timeout error" do
      import = CrossrefImport.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000", status: 408)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response.first
      expect(work[:doi]).to eq("10.1787/gen_papers-v2008-art6-en")
      expect(work[:title]).to eq("Investment climate, capabilities and firm performance")
      expect(work[:year]).to eq(2008)
      expect(work[:month]).to eq(7)
      expect(work[:day]).to eq(26)
      expect(work[:publisher_id]).to eq(1963)
    end

    it "should parse_data incomplete date" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to eq("Sanitary and meteorological notes")
      expect(work[:year]).to eq(1884)
      expect(work[:month]).to eq(8)
      expect(work[:day]).to be_nil
      expect(work[:publisher_id]).to eq(297)
    end

    it "should parse_data date in future" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import_future.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(1)

      work = response[0]
      expect(work[:doi]).to eq("10.1016/j.ejphar.2015.03.018")
      expect(work[:title]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(work[:year]).to eq(2015)
      expect(work[:month]).to eq(5)
      expect(work[:day]).to eq(24)
      expect(work[:publisher_id]).to eq(78)
    end

    it "should parse_data title as second item" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[2]
      expect(work[:doi]).to eq("10.1787/gen_papers-v2008-art4-en")
      expect(work[:title]).to eq("Human capital formation and foreign direct")
    end

    it "should parse_data missing title" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to be_nil
    end

    it "should parse_data missing title journal-issue" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"

      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to eq("The Dublin Journal of Medical Science")
    end

    it "should parse_data missing title missing container-title journal-issue" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["container-title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"

      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to eq("No title")
    end
  end

  context "import_data" do
    it "should import_data" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(10)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(10)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(9)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.1787/gen_papers-v2008-art6-en.")
      expect(alert.target_url).to eq("http://dx.doi.org/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
