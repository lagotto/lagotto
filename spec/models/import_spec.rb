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

    it "should get_data from_index_date" do
      import = Import.new(from_index_date: "2013-09-01")
      body = File.read(fixture_path + 'import.json')
      stub = stub_request(:get, import.query_url).to_return(:body => body)
      response = import.get_data
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
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
  end
end
