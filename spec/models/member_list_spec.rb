require 'rails_helper'

describe MemberList, :type => :model do

  context "query_url" do
    it "should have query string" do
      query = "elife"
      url = "http://api.crossref.org/members?offset=0&query=#{query}&rows=15"
      subject = MemberList.new(query: query, no_network: true)
      expect(subject.query_url).to eq(url)
    end

    it "should have empty query string" do
      url = "http://api.crossref.org/members?offset=0&query=&rows=15"
      subject = MemberList.new(no_network: true)
      expect(subject.query_url).to eq(url)
    end
  end

  context "get_data" do
    it "should get_data query string" do
      query = "elife"
      body = File.read(fixture_path + 'publisher.json')
      subject = MemberList.new(query: query, no_network: true)
      stub = stub_request(:get, subject.query_url).to_return(:body => body)
      response = subject.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data empty query string" do
      body = File.read(fixture_path + 'publisher.json')
      subject = MemberList.new(no_network: true)
      stub = stub_request(:get, subject.query_url).to_return(:body => body)
      response = subject.get_data
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should get_data access denied error" do
      body = File.read(fixture_path + 'access_denied.txt')
      error = "the server responded with status 401 for http://api.crossref.org/members?offset=0&query=&rows=15"
      subject = MemberList.new(no_network: true)
      stub = stub_request(:get, subject.query_url).to_return(:body => body, :status => 401)
      response = subject.get_data
      expect(response).to eq(error: "the server responded with status 401 for http://api.crossref.org/members?offset=0&query=&rows=15", status: 401)
      expect(stub).to have_been_requested

      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPUnauthorized")
      expect(alert.message).to eq(error)
      expect(alert.status).to eq(401)
    end

    it "should get_data timeout error" do
      subject = MemberList.new(no_network: true)
      stub = stub_request(:get, subject.query_url).to_return(:status => 408)
      response = subject.get_data
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/members?offset=0&query=&rows=15", status: 408)
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
      result.extend Hashie::Extensions::DeepFetch
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response.first
      expect(work[:doi]).to eq("10.1787/gen_papers-v2008-art6-en")
      expect(work[:title]).to eq("Investment climate, capabilities and firm performance")
      expect(work[:year]).to eq(2008)
      expect(work[:month]).to eq(7)
      expect(work[:day]).to eq(26)
    end

    it "should parse_data incomplete date" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = import.parse_data(result)
      expect(response.length).to eq(10)

      work = response[5]
      expect(work[:doi]).to eq("10.1007/bf02975686")
      expect(work[:title]).to eq("Sanitary and meteorological notes")
      expect(work[:year]).to eq(1884)
      expect(work[:month]).to eq(8)
      expect(work[:day]).to be_nil
    end
  end

  context "import_data" do
    it "should import_data" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.length).to eq(10)
      expect(response).to eq((1..10).to_a)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with one existing work" do
      work = FactoryGirl.create(:work, :doi => "10.1787/gen_papers-v2008-art6-en")
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      items = import.parse_data(result)
      response = import.import_data(items)
      expect(response.compact.length).to eq(10)
      expect(response).to eq((1..10).to_a)
      expect(Alert.count).to eq(0)
    end

    it "should import_data with missing title" do
      import = CrossrefImport.new
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      items = import.parse_data(result)
      items[0][:title] = nil
      response = import.import_data(items)
      expect(response.compact.length).to eq(9)
      expect(response.compact).to eq((1..9).to_a)
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("ActiveRecord::RecordInvalid")
      expect(alert.message).to eq("Validation failed: Title can't be blank for doi 10.1787/gen_papers-v2008-art6-en.")
      expect(alert.target_url).to eq("http://dx.doi.org/10.1787/gen_papers-v2008-art6-en")
    end
  end
end
