require 'spec_helper'

describe Import do

  before(:each) do
    Date.stub(:today).and_return(Date.new(2014, 7, 5))
    Date.stub(:yesterday).and_return(Date.new(2014, 7, 4))
  end

  context "query_url" do
    it "should have total_results" do
      import = Import.new
      body = File.read(fixture_path + 'import_no_rows.json')
      stub = stub_request(:get, import.query_url(offset = 0, rows = 0)).to_return(:body => body)
      import.total_results.should == 22993
    end
  end

  context "query_url" do
    it "should have default query_url" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with from_update_date" do
      import = Import.new(from_update_date: "2014-07-01")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-01%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with until_update_date" do
      import = Import.new(until_update_date: "2014-07-05")
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-05%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with member_id" do
      import = Import.new(member: 340)
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05%2Cmember%3A340&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with type" do
      import = Import.new(type: 'book-entry')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05%2Ctype%3Abook-entry&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with issn" do
      import = Import.new(issn: '1545-7885')
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05%2Cissn%3A1545-7885&offset=0&rows=1000"
      import.query_url.should eq(url)
    end

    it "should have query_url with sample" do
      import = Import.new(sample: 100)
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&sample=100"
      import.query_url.should eq(url)
    end

    it "should have query_url with offset" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=250&rows=1000"
      import.query_url(offset = 250).should eq(url)
    end

    it "should have query_url with rows" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=250"
      import.query_url(offset = 0, rows = 250).should eq(url)
    end
  end

  context "get_data" do
    it "should get_data default" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should get_data default no data" do
      import = Import.new
      body = File.read(fixture_path + 'import_nil.json')
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should get_data file" do
      input = File.readlines(fixture_path + 'articles.txt')
      import = Import.new(file: input)
      response = import.get_data
      response["message"]["items"].length.should == 2

      item = response["message"]["items"].first
      item["doi"].should eq("10.1371/journal.pone.0040259")
      item["issued"]["date-parts"].should eq([[2012, 7, 11]])
      item["title"].should eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing day" do
      input = File.readlines(fixture_path + 'articles_year_month.txt')
      import = Import.new(file: input)
      response = import.get_data
      response["message"]["items"].length.should == 2

      item = response["message"]["items"].first
      item["doi"].should eq("10.1371/journal.pone.0040259")
      item["issued"]["date-parts"].should eq([[2012, 8]])
      item["title"].should eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing month and day" do
      input = File.readlines(fixture_path + 'articles_year.txt')
      import = Import.new(file: input)
      response = import.get_data
      response["message"]["items"].length.should == 2

      item = response["message"]["items"].first
      item["doi"].should eq("10.1371/journal.pone.0040259")
      item["issued"]["date-parts"].should eq([[2011]])
      item["title"].should eq(["The Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file missing dates" do
      input = File.readlines(fixture_path + 'articles_nil_dates.txt')
      import = Import.new(file: input)
      response = import.get_data
      response["message"]["items"].length.should == 1

      item = response["message"]["items"].first
      item["doi"].should eq("10.1371/journal.pone.0040259")
      item["issued"]["date-parts"].should eq([[]])
      item["title"].should eq(["Eyes Don’t Have It: Lie Detection and Neuro-Linguistic Programming"])
    end

    it "should get_data file non-utf-8 characters" do
      input = []
      File.readlines(fixture_path + 'articles_not_utf8.txt').each { |line| input << ActiveSupport::Multibyte::Unicode.tidy_bytes(line) }
      import = Import.new(file: input)
      response = import.get_data
      response["message"]["items"].length.should == 5

      item = response["message"]["items"].first
      item["doi"].should eq("10.1371/journal.pone.0103093")
      item["issued"]["date-parts"].should eq([[2014, 7, 29]])
      item["title"].should eq(["Capsaicin Induces “Brite” Phenotype in Differentiating 3T3-L1 Preadipocytes"])
    end

    it "should get_data access denied error" do
      import = Import.new
      body = File.read(fixture_path + 'access_denied.txt')
      error = "the server responded with status 401 for http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=1000"
      stub = stub_request(:get, import.query_url).to_return(:body => body, :status => 401)
      response = import.get_data
      response.should eq(error: error, status: 401)
      stub.should have_been_requested

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.message.should eq(error)
      alert.status.should == 401
    end

    it "should get_data timeout error" do
      import = Import.new
      stub = stub_request(:get, import.query_url).to_return(:status => 408)
      response = import.get_data
      response.should eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=from-update-date%3A2014-07-04%2Cuntil-update-date%3A2014-07-04%2Cuntil-pub-date%3A2014-07-05&offset=0&rows=1000", status: 408)
      stub.should have_been_requested

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
    end
  end

  context "parse_data" do
    it "should parse_data default" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response.first
      article[:doi].should eq("10.1787/gen_papers-v2008-art6-en")
      article[:title].should eq("Investment climate, capabilities and firm performance")
      article[:year].should == 2008
      article[:month].should == 7
      article[:day].should == 26
      article[:publisher_id].should == 1963
    end

    it "should parse_data incomplete date" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[5]
      article[:doi].should eq("10.1007/bf02975686")
      article[:title].should eq("Sanitary and meteorological notes")
      article[:year].should == 1884
      article[:month].should == 8
      article[:day].should be_nil
      article[:publisher_id].should == 297
    end

    it "should parse_data title as second item" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[2]
      article[:doi].should eq("10.1787/gen_papers-v2008-art4-en")
      article[:title].should eq("Human capital formation and foreign direct")
    end

    it "should parse_data missing title" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[5]
      article[:doi].should eq("10.1007/bf02975686")
      article[:title].should be_nil
    end

    it "should parse_data missing title journal-issue" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"

      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[5]
      article[:doi].should eq("10.1007/bf02975686")
      article[:title].should eq("The Dublin Journal of Medical Science")
    end

    it "should parse_data missing title missing container-title journal-issue" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["container-title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"

      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[5]
      article[:doi].should eq("10.1007/bf02975686")
      article[:title].should eq("No title")
    end
  end

  context "import_data" do
    it "should import_data" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      response.length.should eq(10)
      response.should eq((1..10).to_a)
      Alert.count.should == 0
    end

    it "should import_data with one existing article" do
      article = FactoryGirl.create(:article, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      response = import.import_data(items)
      response.length.should eq(10)
      response.should eq((1..10).to_a)
      Alert.count.should == 0
    end

    it "should import_data with missing title" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      response.compact.length.should eq(9)
      response.compact.should eq((1..9).to_a)
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("ActiveRecord::RecordInvalid")
      alert.message.should eq("Validation failed: Title can't be blank for doi 10.1787/gen_papers-v2008-art6-en.")
      alert.target_url.should eq("http://api.crossref.org/works/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
