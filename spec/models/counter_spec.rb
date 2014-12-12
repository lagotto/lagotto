require 'rails_helper'

describe Counter, :type => :model do

  subject { FactoryGirl.create(:counter) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0008776") }

  context "CSV report" do
    it "should provide a date range" do
      # array of hashes for the 10 last months, including the current month
      start_date = 10.months.ago.to_date
      end_date = Date.today
      response = subject.date_range(month: start_date.month, year: start_date.year)
      expect(response.count).to eq(11)
      expect(response.last).to eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_report.json'))
      response = CSV.parse(subject.to_csv)
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi", "html", "pdf", "total"])
      expect(response.last).to eq(["10.1371/journal.ppat.1000446", "7489", "1147", "8676"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.ppat.1000446", "112", "95", "45"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_html_report.json'))
      response = CSV.parse(subject.to_csv(format: "html", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response.last).to eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "1"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_pdf_report.json'))
      response = CSV.parse(subject.to_csv(format: "pdf", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB XML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "0"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_xml_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_xml_report.json'))
      response = CSV.parse(subject.to_csv(format: "xml", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0030137", "165", "149", "61"]
      row.fill("0", 4..(dates.length))
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_combined_report.json'))
      response = CSV.parse(subject.to_csv(format: "combined", month: 11, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["doi"] + dates)
      expect(response[3]).to eq(row)
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(subject.to_csv).to be_nil
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Faraday::ResourceNotFound")
      expect(alert.message).to eq("CouchDB report for Counter could not be retrieved.")
      expect(alert.status).to eq(404)
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item'].length).to eq(37)
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(37)
      expect(response[:events_by_month].length).to eq(37)
      expect(response[:events_by_month].first).to eq(month: 1, year: 2010, html: 299, pdf: 90)
      expect(response[:events_url]).to be_nil
      expect(response[:event_count]).to eq(3387)
      expect(response[:event_metrics]).to eq(pdf: 447, html: 2919, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 3387)
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
