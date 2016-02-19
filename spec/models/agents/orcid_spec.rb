require 'rails_helper'

describe Orcid, type: :model, vcr: true do
  subject { FactoryGirl.create(:orcid) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0018011", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the ORCID API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("message-version"=>"1.2", "orcid-profile"=>nil, "orcid-search-results"=>{"orcid-search-result"=>[], "num-found"=>0}, "error-desc"=>nil)
    end

    it "should report if there are events returned by the ORCID API" do
      response = subject.get_data(work_id: work.id)
      expect(response["orcid-search-results"]["num-found"]).to eq(1)
      profile = response["orcid-search-results"]["orcid-search-result"].first
      expect(profile["orcid-profile"]["orcid-identifier"]["uri"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "should catch timeout errors with the ORCID API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://pub.orcid.org/v1.2/search/orcid-bio/?q=digital-object-ids:\"#{work.doi_escaped}\"&rows=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "orcid", work_id: work.pid, readers: 0, total: 0, months: [] }])
    end

    it "should report if there are no events returned by the ORCID API" do
      body = File.read(fixture_path + 'orcid_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(works: [], events: [{ source_id: "orcid", work_id: work.pid, readers: 0, total: 0, months: [] }])
    end

    it "should report if there are events returned by the ORCID API" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))

      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("orcid")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)
      expect(event[:events_url]).to eq("https://orcid.org/orcid-search/quick-search/?searchQuery=\"10.1371%2Fjournal.pone.0018011\"&rows=100")

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work['URL']).to eq("http://orcid.org/0000-0002-0159-2197")
      expect(related_work['author']).to eq([{"family"=>"Eisen", "given"=>"Jonathan A."}])
      expect(related_work['title']).to eq("ORCID profile for Jonathan A. Eisen")
      expect(related_work['container-title']).to eq("ORCID Registry")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 9, 5]])
      expect(related_work['timestamp']).to eq("2013-09-05T00:00:00Z")
      expect(related_work['type']).to eq("entry")
      expect(related_work['related_works']).to eq([{"pid"=> work.pid, "source_id"=>"orcid", "relation_type_id"=>"bookmarks"}])
    end
  end
end
