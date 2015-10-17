require 'rails_helper'

describe CrossrefOrcid, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:crossref_orcid) }

  context "config_fields" do
    it "url_fields" do
      expect(subject.url_fields).to eq([:url])
    end

    it "other_fields" do
      expect(subject.other_fields).to be_empty
    end
  end

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=1000")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-05%2Cuntil-update-date%3A2015-04-05&offset=0&rows=1000")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=250&rows=1000")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=250")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(1782)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "1999-04-05", until_date: "1999-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.queue_jobs(from_date: "1999-04-05", until_date: "1999-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.queue_jobs
      expect(response).to eq(1782)
    end

    it "should report if there are sample works returned by the Crossref REST API" do
      subject.sample = 20
      response = subject.queue_jobs
      expect(response).to eq(20)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.get_data(from_date: "1999-04-05", until_date: "1999-04-05")
      expect(response["message"]["total-results"]).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.get_data
      expect(response["message"]["total-results"]).to eq(1782)
      item = response["message"]["items"].first
      expect(item["DOI"]).to eq("10.1016/j.mmcr.2014.03.001")
    end

    it "should catch errors with the Crossref REST API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_orcid_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq(:works=>[], :events=>[])
    end

    it "should report if there are works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_orcid.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response[:works].length).to eq(10)
      related_work = response[:works].first
      expect(related_work['DOI']).to eq("10.1016/j.mmcr.2014.03.001")
      expect(related_work['related_works'].length).to eq(1)
      related_work = related_work['related_works'].first
      expect(related_work).to eq("pid"=>"http://orcid.org/0000-0001-9344-779X", "source_id"=>"crossref_orcid", "relation_type_id"=>"is_bookmarked_by")

      expect(response[:events].length).to eq(10)
      event = response[:events].first
      expect(event).to eq(:source_id=>"crossref_orcid", :work_id=>"http://doi.org/10.1016/j.mmcr.2014.03.001", :total=>1)
    end
  end
end
