require 'rails_helper'

describe Pmc, type: :model, vcr: true do

  subject { FactoryGirl.create(:pmc) }

  context "CSV report" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it "should provide a date range" do
      # array of hashes for the 10 last months, excluding the current month
      start_date = Time.zone.now.to_date - 10.months
      end_date = Time.zone.now.to_date - 1.month
      response = subject.date_range(month: start_date.month, year: start_date.year)
      expect(response.count).to eq(10)
      expect(response.last).to eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_report.json'))
      response = CSV.parse(subject.to_csv)
      expect(response.count).to eq(25)
      expect(response.first).to eq(["pid_type", "pid", "html", "pdf", "total"])
      expect(response.last).to eq(["doi", "10.1371/journal.ppat.1000446", "9", "6", "15"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.ppat.1000446", "5", "4"]
      row.fill("0", 3..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_html_report.json'))
      response = CSV.parse(subject.to_csv(format: "html", month: 7, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response.last).to eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.pbio.0030137", "0", "0"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_pdf_report.json'))
      response = CSV.parse(subject.to_csv(format: "pdf", month: 7, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.pbio.0040015", "9", "10"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'pmc_combined_report.json'))
      response = CSV.parse(subject.to_csv(format: "combined", month: 7, year: 2013))
      expect(response.count).to eq(25)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response[3]).to eq(row)
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/pmc"
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(subject.to_csv).to be_nil
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Faraday::ResourceNotFound")
      expect(alert.message).to eq("CouchDB report for PMC could not be retrieved.")
      expect(alert.status).to eq(404)
    end
  end

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
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
    let(:a_month_ago) { Time.zone.now - 1.month }
    let(:month) { a_month_ago.month }
    let(:year) { a_month_ago.year }

    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should parse PMC data" do
      config = subject.publisher_configs.first
      publisher_id = config[0]
      journal = config[1].journals.split(" ").first
      stub = stub_request(:get, subject.get_feed_url(publisher_id, month, year, journal)).to_return(:body => File.read(fixture_path + 'pmc_alt.xml'))
      expect(subject.get_feed(month, year)).to be_empty
      expect(subject.parse_feed(month, year)).to be_empty
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(0)
    end
  end

  context "get_data" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
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
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>0, :html=>0, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>nil, :total=>0})
    end

    it "should report if there are no events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'pmc_nil.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response).to eq(events: [{ "unique-ip" => "0", "full-text" => "0", "pdf" => "0", "abstract" => "0", "scanned-summary" => "0", "scanned-page-browse" => "0", "figure" => "0", "supp-data" => "0", "cited-by" => "0", "year" => "2013", "month" => "10" }], :events_by_day=>[], events_by_month: [{ month: 10, year: 2013, html: 0, pdf: 0 }], :events_url=>nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
    end

    it "should report if there are events and event_count returned by the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'pmc.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(2)
      expect(response[:event_count]).to eq(13)
      expect(response[:event_metrics]).to eq(pdf: 4, html: 9, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 13)
    end

    it "should catch timeout errors with the PMC API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://127.0.0.1:5984/pmc_usage_stats_test/", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
