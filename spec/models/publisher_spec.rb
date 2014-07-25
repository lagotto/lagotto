require 'spec_helper'

describe Publisher do

  subject { Publisher.new }

  context "query_url" do
    it "should have query string" do
      string = "elife"
      url = "http://api.crossref.org/members?offset=0&query=elife&rows=20"
      subject.query_url(string).should eq(url)
    end

    it "should have empty query string" do
      url = "http://api.crossref.org/members?offset=0&query=&rows=20"
      subject.query_url.should eq(url)
    end
  end

  context "get_data" do
    it "should get_data query string" do
      string = "elife"
      body = File.read(fixture_path + 'publisher.json')
      stub = stub_request(:get, subject.query_url(string)).to_return(:body => body)
      response = subject.get_data(string)
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should get_data empty query string" do
      body = File.read(fixture_path + 'publisher_nil.json')
      stub = stub_request(:get, subject.query_url).to_return(:body => body)
      response = subject.get_data
      response.should eq(JSON.parse(body))
      stub.should have_been_requested
    end

    it "should get_data access denied error" do
      body = File.read(fixture_path + 'access_denied.txt')
      error = "the server responded with status 401 for http://api.crossref.org/members?offset=0&query=&rows=20"
      stub = stub_request(:get, subject.query_url).to_return(:body => body, :status => 401)
      response = subject.get_data
      response.should eq(error: error, status: 401)
      stub.should have_been_requested

      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPUnauthorized")
      alert.message.should eq(error)
      alert.status.should == 401
    end

    it "should get_data timeout error" do
      stub = stub_request(:get, subject.query_url).to_return(:status => 408)
      response = subject.get_data
      response.should eq(error: "the server responded with status 408 for http://api.crossref.org/members?offset=0&query=&rows=20", status: 408)
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
      alert.target_url.should eq("http://api.crossref.org/works/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
