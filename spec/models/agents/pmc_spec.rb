require 'rails_helper'

describe Pmc, type: :model do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:pmc) }

  let(:publisher) { FactoryGirl.create(:publisher) }
  let(:journal) { "plosbiol" }
  let(:year) { Time.zone.now.year }
  let(:month) { Time.zone.now.month }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url(publisher_id: publisher.id, journal: journal, year: year, month: month)).to eq("http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=2015&month=4&jrid=plosbiol&user=username&password=password")
    end

    it "last year" do
      expect(subject.get_query_url(publisher_id: publisher.id, journal: journal, year: 2014, month: month)).to eq("http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=2014&month=4&jrid=plosbiol&user=username&password=password")
    end

    it "different journal" do
      expect(subject.get_query_url(publisher_id: publisher.id, journal: "plosone", year: year, month: month)).to eq("http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=2015&month=4&jrid=plosone&user=username&password=password")
    end
  end

  context "get_total" do
    it "default" do
      expect(subject.get_total).to eq(1)
    end

    it "for six months" do
      expect(subject.get_total(months: 6)).to eq(6)
    end
  end

  context "queue_jobs" do
    it "default" do
      expect(subject.queue_jobs).to eq(1)
    end

    it "for six months" do
      expect(subject.queue_jobs(from_date: "2014-10-05")).to eq(6)
    end

    it "for six months and two journals" do
      subject = FactoryGirl.create(:pmc_with_multiple_journals)
      expect(subject.queue_jobs(from_date: "2014-10-05")).to eq(12)
    end
  end

  context "get_data" do
    it "should report if there are no events returned by the PMC API" do
      body = File.read(fixture_path + 'pmc_nil.xml')
      options = { publisher_id: publisher.id, journal: "ploscurrentss", year: 2013, month: 10 }
      stub = stub_request(:get, subject.get_query_url(options)).to_return(:body => body)
      response = subject.get_data(options)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the PMC API" do
      body = File.read(fixture_path + 'pmc.xml')
      options = { publisher_id: publisher.id, journal: journal, year: 2013, month: 10 }
      stub = stub_request(:get, subject.get_query_url(options)).to_return(:body => body)
      response = subject.get_data(options)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PMC API" do
      options = { publisher_id: publisher.id, journal: journal, year: year, month: month, source_id: subject.source_id }
      stub = stub_request(:get, subject.get_query_url(options)).to_return(:status => [408])
      response = subject.get_data(options)
      expect(response).to eq(error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=2015&month=4&jrid=plosbiol&user=username&password=password", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are events returned by the PMC API" do
      body = File.read(fixture_path + 'pmc.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(5228)
      expect(response[2][:relation]).to eq("subj_id"=>"https://www.ncbi.nlm.nih.gov/pmc",
                                           "obj_id"=>"http://doi.org/10.1371/journal.pbio.0030085",
                                           "relation_type_id"=>"views",
                                           "total"=>128,
                                           "source_id"=>"pmc_html")

      expect(response[3][:relation]).to eq("subj_id"=>"https://www.ncbi.nlm.nih.gov/pmc",
                                           "obj_id"=>"http://doi.org/10.1371/journal.pbio.0030085",
                                           "relation_type_id"=>"downloads",
                                           "total"=>90,
                                           "source_id"=>"pmc_pdf")
    end

    it "should report errors with the PMC API" do
      body = File.read(fixture_path + 'pmc_nil.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result)
      expect(response).to eq(error: "wrong data requested")
    end

    it "should catch timeout errors with the PMC API" do
      result = { error: "the server responded with status 408 for http://www.pubmedcentral.nih.gov/utils/publisher/pmcstat/pmcstat.cgi?year=2015&month=4&jrid=plosbiol&user=username&password=password", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end
end
