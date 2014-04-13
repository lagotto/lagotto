require 'spec_helper'

describe Pmc do

  context "class methods" do
    subject { Pmc }

    it "should provide a date range" do
      # array of hashes for the 10 last months, excluding the current month
      start_date = 10.months.ago.to_date
      end_date = 1.month.ago.to_date
      response = subject.date_range(month: start_date.month, year: start_date.year, source: "pmc")
      response.count.should == 10
      response.last.should eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
      response = CSV.parse(subject.to_csv)
      response.count.should == 25
      response.first.should eq(["doi", "html", "pdf", "total"])
      response.last.should eq(["10.1371/journal.ppat.1000446", "9", "6", "15"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year, source: "pmc").map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.ppat.1000446", "5", "4"]
      row.fill("0", 3..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_html_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
      response = CSV.parse(subject.to_csv(format: "html", month: 11, year: 2013))
      response.count.should == 25
      response.first.should eq(["doi"] + dates)
      response.last.should eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year, source: "pmc").map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0030137", "0", "0"]
      row.fill("0", 3..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_pdf_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
      response = CSV.parse(subject.to_csv(format: "pdf", month: 11, year: 2013))
      response.count.should == 25
      response.first.should eq(["doi"] + dates)
      response[2].should eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year, source: "pmc").map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0040015", "9", "10"]
      row.fill("0", 3..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/pmc_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_combined_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
      response = CSV.parse(subject.to_csv(format: "combined", month: 11, year: 2013))
      response.count.should == 25
      response.first.should eq(["doi"] + dates)
      response[3].should eq(row)
    end
  end

  let(:pmc) { FactoryGirl.create(:pmc) }

  it "should report that there are no events if the doi is missing" do
    article = FactoryGirl.build(:article, :doi => "")
    pmc.get_data(article).should eq(events: [], event_count: nil)
  end

  it "should report that there are no events if article was published on the same day" do
    date = Time.zone.today
    article = FactoryGirl.create(:article, year: date.year, month: date.month, day: date.day)
    pmc.get_data(article).should eq(events: [], event_count: nil)
  end

  context "save PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }
    let(:journal) { "ajrccm" }

    it "should fetch and save PMC data" do
      stub = stub_request(:get, pmc.get_feed_url(month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc_alt.xml'), :status => 200)
      pmc.get_feed(month, year).should be_empty
      file = "#{Rails.root}/data/pmcstat_#{journal}_#{month}_#{year}.xml"
      File.exist?(file).should be_true
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "parse PMC data" do
    let(:month) { 1.month.ago.month }
    let(:year) { 1.month.ago.year }
    let(:journal) { "ajrccm" }

    before(:each) do
      pmc.put_alm_data(pmc.url)
    end

    after(:each) do
      pmc.delete_alm_data(pmc.url)
    end

    it "should parse PMC data" do
      stub = stub_request(:get, pmc.get_feed_url(month, year, journal)).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'pmc_alt.xml'), :status => 200)
      pmc.get_feed(month, year).should be_empty
      pmc.parse_feed(month, year).should be_empty
      stub.should have_been_requested
      Alert.count.should == 0
    end
  end

  context "use the PMC API" do

    before(:each) do
      pmc.put_alm_data(pmc.url)
    end

    after(:each) do
      pmc.delete_alm_data(pmc.url)
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      pmc.get_data(article).should eq(events: [{ "unique-ip" => "0", "full-text" => "0", "pdf" => "0", "abstract" => "0", "scanned-summary" => "0", "scanned-page-browse" => "0", "figure" => "0", "supp-data" => "0", "cited-by" => "0", "year" => "2013", "month" => "10" }], event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = pmc.get_data(article)
      response[:events].length.should eq(2)
      response[:event_count].should eq(13)
      response[:event_metrics].should eq(pdf: 4, html: 9, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 13)
      stub.should have_been_requested
    end

    it "should catch errors with the PMC API" do
      article = FactoryGirl.create(:article, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, pmc.get_query_url(article)).to_return(:status => [408])
      pmc.get_data(article, options = { :source_id => pmc.id }).should be_nil
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == pmc.id
    end
  end
end
