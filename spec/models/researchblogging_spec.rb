require 'rails_helper'

describe Researchblogging, type: :model do
  subject { FactoryGirl.create(:researchblogging) }

  context "get_data" do
    let(:auth) { ActionController::HttpAuthentication::Basic.encode_credentials(subject.username, subject.password) }

    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'researchblogging.xml')
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, "http://researchbloggingconnect.com/blogposts?article=doi:#{work.doi_escaped}&count=100").with(:headers => { :authorization => auth }).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124") }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "researchblogging", work_id: work.pid, total: 0, extra: [], days: [], months: [] }])
    end

    it "should report if there are no events returned by the ResearchBlogging API" do
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(works: [], events: [{ source_id: "researchblogging", work_id: work.pid, total: 0, extra: [], days: [], months: [] }])
    end

    it "should report if there are events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2009-07-01")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("researchblogging")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(8)
      expect(event[:events_url]).to eq(subject.get_events_url(work))
      expect(event[:days].length).to eq(7)
      expect(event[:days].first).to eq(year: 2009, month: 7, day: 6, total: 1)
      expect(event[:months].length).to eq(7)
      expect(event[:months].first).to eq(year: 2009, month: 7, total: 1)

      expect(response[:works].length).to eq(8)
      related_work = response[:works].first
      expect(related_work['URL']).to eq("http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/")
      expect(related_work['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(related_work['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(related_work['container-title']).to eq("Laika's Medliblog")
      expect(related_work['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(related_work['type']).to eq("post")

      extra = event[:extra].first
      expect(extra[:event_time]).to eq("2012-10-27T11:32:09Z")
      expect(extra[:event_url]).to eq(extra[:event]["post_URL"])
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(extra[:event_csl]['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(extra[:event_csl]['container-title']).to eq("Laika's Medliblog")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(extra[:event_csl]['type']).to eq("post")
    end

    it "should report if there is one event returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2012-10-01")
      body = File.read(fixture_path + 'researchblogging_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("researchblogging")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)
      expect(event[:events_url]).to eq(subject.get_events_url(work))
      expect(event[:days].length).to eq(1)
      expect(event[:days].first).to eq(year: 2012, month: 10, day: 27, total: 1)
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2012, month: 10, total: 1)

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work['URL']).to eq("http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/")
      expect(related_work['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(related_work['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(related_work['container-title']).to eq("Laika's Medliblog")
      expect(related_work['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(related_work['type']).to eq("post")

      extra = event[:extra].first
      expect(extra[:event_time]).to eq("2012-10-27T11:32:09Z")
      expect(extra[:event_url]).to eq(extra[:event]["post_URL"])
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Spoetnik", "given"=>"Laika"}])
      expect(extra[:event_csl]['title']).to eq("Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan")
      expect(extra[:event_csl]['container-title']).to eq("Laika's Medliblog")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2012, 10, 27]])
      expect(extra[:event_csl]['type']).to eq("post")
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      result = { error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&work=doi:#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
