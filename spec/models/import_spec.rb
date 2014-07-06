require 'spec_helper'

describe Import do

  before(:each) do
    Date.stub(:today).and_return(Date.new(2013, 9, 5))
    Date.stub(:yesterday).and_return(Date.new(2013, 9, 4))
  end

  context "query_url" do
    it "should have default query_url" do
      import = Import.new
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with from_index_date" do
      import = Import.new(from_index_date: "2013-09-01")
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-01%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with until_index_date" do
      import = Import.new(until_index_date: "2013-09-05")
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-05%2Ctype%3Ajournal-article&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with offset" do
      import = Import.new(offset: 250)
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&offset=250&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with member_id" do
      import = Import.new(member: 340)
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article%2Cmember%3A340&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with type" do
      import = Import.new(type: 'book-entry')
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Abook-entry&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with issn" do
      import = Import.new(issn: '1545-7885')
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article%2Cissn%3A1545-7885&offset=0&rows=500"
      import.query_url.should eq(url)
    end

    it "should have query_url with sample" do
      import = Import.new(sample: 100)
      url = "http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&sample=100"
      import.query_url.should eq(url)
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

    it "should get_data access denied error" do
      import = Import.new
      body = File.read(fixture_path + 'import_access_denied.txt')
      error = "the server responded with status 401 for http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&offset=0&rows=500"
      stub = stub_request(:get, import.query_url).to_return(:body => body, :status => 401)
      response = import.get_data
      response.should eq(error: error)
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
      response.should eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=from-index-date%3A2013-09-04%2Cuntil-index-date%3A2013-09-04%2Ctype%3Ajournal-article&offset=0&rows=500")
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
      result.extend Hashie::Extensions::DeepFetch
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response.first
      article[:doi].should eq("10.1787/gen_papers-v2008-art6-en")
      article[:title].should eq("Investment climate, capabilities and firm performance")
      article[:year].should == 2008
      article[:month].should == 7
      article[:day].should ==26
    end

    it "should parse_data incomplete date" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = import.parse_data(result)
      response.length.should eq(10)

      article = response[5]
      article[:doi].should eq("10.1007/bf02975686")
      article[:title].should eq("Sanitary and meteorological notes")
      article[:year].should == 1884
      article[:month].should == 8
      article[:day].should be_nil
    end
  end

  context "import_data" do
    it "should import_data" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
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
      result.extend Hashie::Extensions::DeepFetch
      items = import.parse_data(result)
      response = import.import_data(items)
      response.compact.length.should eq(10)
      response.should eq((1..10).to_a)
      Alert.count.should == 0
    end

    it "should import_data with missing title" do
      import = Import.new
      body = File.read(fixture_path + 'import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      response.compact.length.should eq(9)
      response.compact.should eq((1..9).to_a)
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("ActiveRecord::RecordInvalid")
      alert.message.should eq("Validation failed: Title can't be blank for doi 10.1787/gen_papers-v2008-art6-en.")
      alert.target_url.should eq("http://api.crossref.org/works/10.1371/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
