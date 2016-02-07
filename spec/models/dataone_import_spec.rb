require 'rails_helper'

describe DataoneImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:dataone_import) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=dateModified%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq( "https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=dateModified%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=0&start=0&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=dateModified%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=1000&start=0&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(140)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2015-04-05", until_date: "2015-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the DataONE Search API" do
      response = subject.queue_jobs(from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the DataONE Search API" do
      response = subject.queue_jobs
      expect(response).to eq(140)
    end

    it "should report if there are sample works returned by the DataONE Search API" do
      subject.sample = 20
      response = subject.queue_jobs
      expect(response).to eq(140)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the DataONE Search API" do
      response = subject.get_data(from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the DataONE Search API" do
      response = subject.get_data
      expect(response["response"]["numFound"]).to eq(140)
      doc = response["response"]["docs"].first
      expect(doc["id"]).to eq("http://dx.doi.org/10.5061/dryad.5rg54?ver=2015-04-07T11:30:54.986-04:00")
    end

    it "should catch errors with the DataONE Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://cn.dataone.org/cn/v1/query/solr/?fl=id%2Ctitle%2Cauthor%2CdatePublished%2CauthoritativeMN%2CdateModified&q=dateModified%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2BformatType%3AMETADATA&rows=0&start=0&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the DataONE Search API" do
      body = File.read(fixture_path + 'plos_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq(works: [])
    end

    it "should report if there are works returned by the DataONE Search API" do
      body = File.read(fixture_path + 'dataone_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response[:works].length).to eq(61)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"George", "given"=>"Sangster,"}])
      expect(related_work['title']).to eq("Fig. S1")
      expect(related_work['container-title']).to be_nil
      expect(related_work['issued']).to eq("date-parts"=>[[2014, 9, 4]])
      expect(related_work['type']).to eq("dataset")
      expect(related_work['DOI']).to eq("10.5061/dryad.m4g2n/1")
    end
  end
end
