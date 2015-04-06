require 'rails_helper'

describe Counter, type: :model, vcr: true do

  subject { FactoryGirl.create(:counter) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776") }

  context "CSV report" do
    before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it "should provide a date range" do
      # array of hashes for the 10 last months, including the current month
      start_date = Time.zone.now.to_date - 10.months
      end_date = Time.zone.now.to_date
      response = subject.date_range(month: start_date.month, year: start_date.year)
      expect(response.count).to eq(11)
      expect(response.last).to eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_report.json'))
      response = CSV.parse(subject.to_csv(name: "counter"))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["pid_type", "pid", "html", "pdf", "total"])
      expect(response.last).to eq(["doi", "10.1371/journal.ppat.1000446", "7489", "1147", "8676"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.ppat.1000446", "92", "58", "82"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_html_report.json'))
      response = CSV.parse(subject.to_csv(name: "counter", format: "html", month: 7, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response.last).to eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.pbio.0020413", "0", "1", "3"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_pdf_report.json'))
      response = CSV.parse(subject.to_csv(name: "counter", format: "pdf", month: 7, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB XML report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.pbio.0020413", "0", "0", "0"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_xml_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_xml_report.json'))
      response = CSV.parse(subject.to_csv(name: "counter", format: "xml", month: 7, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response[2]).to eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Time.zone.now.to_date - 2.months
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["doi", "10.1371/journal.pbio.0030137", "68", "87", "112"]
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_combined_report.json'))
      response = CSV.parse(subject.to_csv(name: "counter", format: "combined", month: 7, year: 2013))
      expect(response.count).to eq(27)
      expect(response.first).to eq(["pid_type", "pid"] + dates)
      expect(response[3]).to eq(row)
    end

    it "should report an error if the CouchDB design document can't be retrieved" do
      FactoryGirl.create(:fatal_error_report_with_admin_user)
      url = "#{ENV['COUCHDB_URL']}/_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:status => [404])
      expect(subject.to_csv(name: "counter")).to be_blank
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Faraday::ResourceNotFound")
      expect(alert.message).to eq("CouchDB report for counter could not be retrieved.")
      expect(alert.status).to eq(404)
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the Counter API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Counter API" do
      response = subject.get_data(work)
      expect(response["rest"]["response"]["criteria"]).to eq("year"=>"all", "month"=>"all", "journal"=>"all", "doi"=>work.doi)
      expect(response["rest"]["response"]["results"]["total"]["total"]).to eq("5666")
      expect(response["rest"]["response"]["results"]["item"].length).to eq(63)
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.plosreports.org/services/rest?method=usage.stats&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(metrics: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(metrics: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are no events returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(metrics: { source: "counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are events returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:metrics][:total]).to eq(3387)
      expect(response[:metrics][:pdf]).to eq(447)
      expect(response[:metrics][:html]).to eq(2919)
      expect(response[:metrics][:extra].length).to eq(37)
      expect(response[:metrics][:months].length).to eq(37)
      expect(response[:metrics][:months].first).to eq(month: 1, year: 2010, html: 299, pdf: 90, total: 390)
      expect(response[:metrics][:events_url]).to be_nil
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
