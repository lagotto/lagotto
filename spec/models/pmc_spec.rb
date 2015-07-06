require 'rails_helper'

describe Pmc, type: :model, vcr: true do

  subject { FactoryGirl.create(:pmc) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.create(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  context "save PMC data" do
    let(:a_month_ago) { Time.zone.now - 1.month }
    let(:month) { a_month_ago.month }
    let(:year) { a_month_ago.year }

    it "should fetch and save PMC data" do
      config = subject.publisher_configs.first
      publisher_id = config[0]
      journal = config[1].journals.split(" ").first
      stub = stub_request(:get, subject.get_feed_url(publisher_id, month, year, journal)).to_return(:body => File.read(fixture_path + 'pmc_alt.xml'))
      expect(subject.get_feed(month, year)).to be_empty
      file = "#{Rails.root}/data/pmcstat_#{journal}_#{month}_#{year}.xml"
      expect(File.exist?(file)).to be true
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(0)
    end
  end

  context "parse PMC data" do
    let(:month) { 1 }
    let(:year) { 2014 }
    let(:journal) { "ajrccm" }
    let(:filename) { "pmcstat_#{journal}_#{month}_#{year}.xml" }
    let(:file) { "#{Rails.root}/data/" + filename }

    before(:each) do
      subject.put_lagotto_data(subject.url_db)
      FileUtils.cp(fixture_path + 'pmc_alt.xml', file)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.url_db)
      FileUtils.rm file
    end

    it "should parse PMC data" do
      config = subject.publisher_configs.first
      publisher_id = config[0]
      journal = config[1].journals.split(" ").first
      expect(subject.parse_feed(month, year)).to be_empty
      expect(Alert.count).to eq(0)
    end

    it "should parse file" do
      expect(subject.parse_file(filename, month, year)).to eq("0")
    end

    it "should parse work" do
      document = Nokogiri::XML(File.read(file))
      work = document.xpath("//article").first
      expect(subject.parse_work(work, month, year)).to eq("views"=>[{"unique-ip"=>"17", "full-text"=>"20", "pdf"=>"3", "abstract"=>"0", "scanned-summary"=>"0", "scanned-page-browse"=>"0", "figure"=>"0", "supp-data"=>"0", "cited-by"=>"0", "doi"=>"10.1164/rccm.200612-1772OC", "year"=>"2014", "month"=>"1"}])
    end
  end

  context "get_data" do
    before(:each) do
      subject.put_lagotto_data(subject.url_db)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.url_db)
    end

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, doi: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://127.0.0.1:5984/pmc_usage_stats_test/#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, doi: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "pmc", work: work.pid, pdf: 0, html: 0, total: 0, events_url: nil, extra: [], months: [] })
    end

    it "should report if there are no events returned by the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "pmc", work: work.pid, :pdf=>0, :html=>0, :total=>0, :events_url=>nil, :extra=>[{"unique-ip"=>"0", "full-text"=>"0", "pdf"=>"0", "abstract"=>"0", "scanned-summary"=>"0", "scanned-page-browse"=>"0", "figure"=>"0", "supp-data"=>"0", "cited-by"=>"0", "year"=>"2013", "month"=>"10"}], :months=>[{:month=>10, :year=>2013, :html=>0, :pdf=>0, :total=>0}]})
    end

    it "should report if there are events returned by the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:extra].length).to eq(2)
      expect(response[:events][:total]).to eq(13)
      expect(response[:events][:pdf]).to eq(4)
      expect(response[:events][:html]).to eq(9)
      expect(response[:events][:events_url]).to eq("http://www.ncbi.nlm.nih.gov/pmc/works/PMC#{work.pmcid}")
      expect(response[:events][:months]).to eq([{:month=>9, :year=>2013, :html=>3, :pdf=>2, :total=>5}, {:month=>10, :year=>2013, :html=>6, :pdf=>2, :total=>8}])
    end

    it "should catch timeout errors with the PMC API" do
      work = FactoryGirl.create(:work, doi: "10.2307/683422")
      result = { error: "the server responded with status 408 for http://127.0.0.1:5984/pmc_usage_stats_test/", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
