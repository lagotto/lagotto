require 'spec_helper'

describe Counter do

  subject { FactoryGirl.create(:counter) }

  let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776") }

  context "CSV report" do
    it "should provide a date range" do
      # array of hashes for the 10 last months, including the current month
      start_date = 10.months.ago.to_date
      end_date = Date.today
      response = subject.date_range(month: start_date.month, year: start_date.year)
      response.count.should == 11
      response.last.should eq(month: end_date.month, year: end_date.year)
    end

    it "should format the CouchDB report as csv" do
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/counter"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_report.json'))
      response = CSV.parse(subject.to_csv)
      response.count.should == 27
      response.first.should eq(["doi", "html", "pdf", "total"])
      response.last.should eq(["10.1371/journal.ppat.1000446", "7489", "1147", "8676"])
    end

    it "should format the CouchDB HTML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.ppat.1000446", "112", "95", "45"]
      row.fill("0", 4..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/counter_html_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_html_report.json'))
      response = CSV.parse(subject.to_csv(format: "html", month: 11, year: 2013))
      response.count.should == 27
      response.first.should eq(["doi"] + dates)
      response.last.should eq(row)
    end

    it "should format the CouchDB PDF report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "1"]
      row.fill("0", 4..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/counter_pdf_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_pdf_report.json'))
      response = CSV.parse(subject.to_csv(format: "pdf", month: 11, year: 2013))
      response.count.should == 27
      response.first.should eq(["doi"] + dates)
      response[2].should eq(row)
    end

    it "should format the CouchDB XML report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0020413", "0", "0", "0"]
      row.fill("0", 4..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/counter_xml_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_xml_report.json'))
      response = CSV.parse(subject.to_csv(format: "xml", month: 11, year: 2013))
      response.count.should == 27
      response.first.should eq(["doi"] + dates)
      response[2].should eq(row)
    end

    it "should format the CouchDB combined report as csv" do
      start_date = Date.new(2013, 11, 1)
      dates = subject.date_range(month: start_date.month, year: start_date.year).map { |date| "#{date[:year]}-#{date[:month]}" }
      row = ["10.1371/journal.pbio.0030137", "165", "149", "61"]
      row.fill("0", 4..(dates.length))
      url = "#{CONFIG[:couchdb_url]}_design/reports/_view/counter_combined_views"
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_combined_report.json'))
      response = CSV.parse(subject.to_csv(format: "combined", month: 11, year: 2013))
      response.count.should == 27
      response.first.should eq(["doi"] + dates)
      response[3].should eq(row)
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      subject.get_data(article).should eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      subject.get_data(article).should eq({})
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'counter_nil.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      response['rest']['response']['results']['item'].should be_nil
      stub.should have_been_requested
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body)
      response = subject.get_data(article)
      response.should eq(Hash.from_xml(body))
      response['rest']['response']['results']['item'].length.should eq(37)
      stub.should have_been_requested
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
      response = subject.get_data(article, source_id: subject.id)
      response.should eq(error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}", :status=>408)
      stub.should have_been_requested
      Alert.count.should == 1
      alert = Alert.first
      alert.class_name.should eq("Net::HTTPRequestTimeOut")
      alert.status.should == 408
      alert.source_id.should == subject.id
    end
  end

  context "parse_data" do
    let(:null_response) { { events: [], :events_by_day=>[], :events_by_month=>[], events_url: nil, event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 } } }

    it "should report if the doi is missing" do
      article = FactoryGirl.build(:article, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      article = FactoryGirl.build(:article, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      subject.parse_data(result, article).should eq(null_response)
    end

    it "should report if there are no events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response.should eq(null_response)
    end

    it "should report if there are events and event_count returned by the Counter API" do
      body = File.read(fixture_path + 'counter.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, article)
      response[:events].length.should eq(37)
      response[:events_by_month].length.should eq(37)
      response[:events_by_month].first.should eq(month: 1, year: 2010, html: 299, pdf: 90)
      response[:events_url].should be_nil
      response[:event_count].should eq(3387)
      response[:event_metrics].should eq(pdf: 447, html: 2919, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 3387)
    end

    it "should catch timeout errors with the Counter API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{article.doi_escaped}", status: 408 }
      response = subject.parse_data(result, article)
      response.should eq(result)
    end
  end
end
