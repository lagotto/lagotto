require 'rails_helper'

describe PlosImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:plos_import) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=%2Bpublication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=%2Bpublication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=0&start=0&wt=json")
    end

    it "with different from_pub_date and until_pub_date" do
      expect(subject.get_query_url(from_pub_date: "2015-04-05", until_pub_date: "2015-04-05")).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=%2Bpublication_date%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(466)
    end

    it "with no works" do
      expect(subject.get_total(from_pub_date: "2015-04-05", until_pub_date: "2015-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the PLOS Search API" do
      response = subject.queue_jobs(from_pub_date: "2015-04-05", until_pub_date: "2015-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the PLOS Search API" do
      response = subject.queue_jobs
      expect(response).to eq(466)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the PLOS Search API" do
      response = subject.get_data(nil, from_pub_date: "2015-04-05", until_pub_date: "2015-04-05")
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the PLOS Search API" do
      response = subject.get_data(nil)
      expect(response["response"]["numFound"]).to eq(466)
      doc = response["response"]["docs"].first
      expect(doc["id"]).to eq("10.1371/journal.pone.0123874")
    end

    it "should catch errors with the PLOS Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(nil, rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=%2Bpublication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=0&start=0&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, nil)).to eq(works: [])
    end

    it "should report if there are works returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(29)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Alsteens", "given"=>"David"}, {"family"=>"Beaussart", "given"=>"Audrey"}, {"family"=>"El Kirat Chatel", "given"=>"Sofiane"}, {"family"=>"Sullan", "given"=>"Ruby May A."}, {"family"=>"Dufrêne", "given"=>"Yves F."}])
      expect(related_work['title']).to eq("Atomic Force Microscopy: A New Look at Pathogens")
      expect(related_work['container-title']).to eq("PLOS Pathogens")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 9, 5]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1371/journal.ppat.1003516")
    end
  end
end
