require 'spec_helper'

describe Counter do

  subject { FactoryGirl.create(:counter) }

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
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
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
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_html_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
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
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_pdf_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
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
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_xml_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
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
      stub = stub_request(:get, url).to_return(:body => File.read(fixture_path + 'counter_combined_report.json'), :status => 200, :headers => { "Content-Type" => "application/json" })
      response = CSV.parse(subject.to_csv(format: "combined", month: 11, year: 2013))
      response.count.should == 27
      response.first.should eq(["doi"] + dates)
      response[3].should eq(row)
    end
  end

  context "use the Counter API" do
    it "should report that there are no events if the doi is missing" do
      article_without_doi = FactoryGirl.build(:article, :doi => "")
      subject.parse_data(article_without_doi).should eq(events: [], event_count: nil)
    end

    context "use the Counter API" do
      it "should report if there are no events and event_count returned by the Counter API" do
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0044294")
        body = File.read(fixture_path + 'counter_nil.xml')
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 404)
        subject.parse_data(article).should eq(events: [], event_count: 0, event_metrics: { pdf: 0, html: 0, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 0 })
        stub.should have_been_requested
      end

      it "should report if there are events and event_count returned by the Counter API" do
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0008776")
        body = File.read(fixture_path + 'counter.xml')
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:body => body, :status => 200)
        response = subject.parse_data(article)
        response[:events].length.should eq(37)
        response[:event_count].should eq(3387)
        response[:event_metrics].should eq(pdf: 447, html: 2919, shares: nil, groups: nil, comments: nil, likes: nil, citations: nil, total: 3387)
        stub.should have_been_requested
      end

      it "should catch errors with the Counter API" do
        article = FactoryGirl.build(:article, :doi => "10.1371/journal.pone.0000001")
        stub = stub_request(:get, subject.get_query_url(article)).to_return(:status => [408])
        subject.parse_data(article, source_id: subject.id).should be_nil
        stub.should have_been_requested
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("Net::HTTPRequestTimeOut")
        alert.status.should == 408
        alert.source_id.should == subject.id
      end
    end
  end
end
