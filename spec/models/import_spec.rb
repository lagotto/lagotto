require 'rails_helper'

describe Import, :type => :model do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  context "query_url" do
    it "should have total_results" do
      import = Import.new
      body = File.read(fixture_path + 'import_no_rows.json')
      stub = stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => body)
      expect(import.total_results).to eq(22993)
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with from_update_date" do
      import = Import.new(from_update_date: "2013-09-01")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-01%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with until_update_date" do
      import = Import.new(until_update_date: "2013-09-05")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with member_id" do
      import = Import.new(member: 340)
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Cmember%3A340&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with type" do
      import = Import.new(type: 'book-entry')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Ctype%3Abook-entry&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with issn" do
      import = Import.new(issn: '1545-7885')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05%2Cissn%3A1545-7885&offset=0&rows=1000"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with sample" do
      import = Import.new(sample: 100)
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&sample=100"
      expect(import.query_url).to eq(url)
    end

    it "should have query_url with offset" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=250&rows=1000"
      expect(import.query_url(offset = 250)).to eq(url)
    end

    it "should have query_url with rows" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=250"
      expect(import.query_url(offset = 0, rows = 250)).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data default no data" do
      import = Import.new
      body = File.read(fixture_path + 'import_nil.json')
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data file" do
      input = File.readlines(fixture_path + 'works.txt')
      import = Import.new(file: input)
      response = import.get_data
      expect(response["message"]["items"].length).to eq(2)

      item = response["message"]["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2012, 7, 11]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing day" do
      input = File.readlines(fixture_path + 'works_year_month.txt')
      import = Import.new(file: input)
      response = import.get_data
      expect(response["message"]["items"].length).to eq(2)

      item = response["message"]["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2012, 8]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing month and day" do
      input = File.readlines(fixture_path + 'works_year.txt')
      import = Import.new(file: input)
      response = import.get_data
      expect(response["message"]["items"].length).to eq(2)

      item = response["message"]["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[2011]])
      expect(item["title"]).to eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing dates" do
      input = File.readlines(fixture_path + 'works_nil_dates.txt')
      import = Import.new(file: input)
      response = import.get_data
      expect(response["message"]["items"].length).to eq(1)

      item = response["message"]["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0040259")
      expect(item["issued"]["date-parts"]).to eq([[]])
      expect(item["title"]).to eq(["Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file non-utf-8 characters" do
      input = []
      File.readlines(fixture_path + 'works_not_utf8.txt').each { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) }
      import = Import.new(file: input)
      response = import.get_data
      expect(response["message"]["items"].length).to eq(5)

      item = response["message"]["items"].first
      expect(item["doi"]).to eq("10.1371/journal.pone.0103093")
      expect(item["issued"]["date-parts"]).to eq([[2014, 7, 29]])
      expect(item["title"]).to eq(["Capsaicin Induces “Brite” Phenotype in Differentiating 3T3-L1 Preadipocytes"])
    end

    it "should get_data access denied error" do
      import = Import.new
      body = File.read(fixture_path + 'access_denied.txt')
      error = "the server responded with status 401 for http://api.crossref.org/works?filter=from-update-date%3A2013-09-04%2Cuntil-update-date%3A2013-09-05%2Cuntil-pub-date%3A2013-09-05&offset=0&rows=1000"
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
      import = Import.new
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
      import = Import.new
      body = File.read(fixture_path + 'import.json')
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
      import = Import.new
      body = File.read(fixture_path + 'import.json')
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

    it "should parse_data title as second item" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[2]
      expect(work[:doi]).to eq("10.1787/gen_papers-v2008-art4-en")
      expect(work[:title]).to eq("Human capital formation and foreign direct")
    end

    it "should parse_data missing title" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to be_nil
    end

    it "should parse_data missing title journal-issue" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
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
      import = Import.new
      body = File.read(fixture_path + 'import.json')
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
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.length).to eq(10)
      expect(response).to eq((1..10).to_a)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.length).to eq(10)
      expect(response).to eq((1..10).to_a)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(9)
      expect(response.compact).to eq((1..9).to_a)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.1787/gen_papers-v2008-art6-en.")
      expect(alert.target_url).to eq("http://api.crossref.org/works/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
