require 'rails_helper'

describe Github, type: :model, vcr: true do
  subject { FactoryGirl.create(:github) }

  let(:work) { FactoryGirl.create(:work, :canonical_url => "https://github.com/ropensci/alm") }

  context "get_data" do
    it "should report that there are no events if the canonical_url is missing" do
      work = FactoryGirl.create(:work, :canonical_url => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.create(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Github API" do
      body = File.read(fixture_path + 'github.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the github API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:extra) { { "stargazers_count"=>0, "stargazers_url"=>"https://api.github.com/repos/articlemetrics/pyalm/stargazers", "forks_count"=>0, "forks_url"=>"https://api.github.com/repos/articlemetrics/pyalm/forks" } }
    it "should report if the canonical_url is missing" do
      work = FactoryGirl.create(:work, :canonical_url => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "github", work_id: work.pid, readers: 0, total: 0, extra: {}, days: [], months: []}])
    end

    it "should report that there are no events if the canonical_url is not a Github URL" do
      work = FactoryGirl.create(:work, :canonical_url => "https://code.google.com/p/gwtupload/")
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "github", work_id: work.pid, readers: 0, total: 0, extra: {}, days: [], months: []}])
    end

    it "should report if there are no events and event_count returned by the Github API" do

      stargazers_stub = stub_request(:get, subject.get_query_url(work) + "/stargazers").to_return(:body => "[]")
      body = File.read(fixture_path + 'github_nil.json')
      result = JSON.parse(body)
      extra = { "stargazers_count"=>0, "stargazers_url"=>"https://api.github.com/repos/articlemetrics/pyalm/stargazers", "forks_count"=>0, "forks_url"=>"https://api.github.com/repos/articlemetrics/pyalm/forks" }
      response = subject.parse_data(result, work)
      expect(response).to eq(works: [], events: [{ source_id: "github", work_id: work.pid, readers: 0, total: 0, extra: extra, months: [], days: [] }])
    end

    it "should report if there are events and event_count returned by the Github API" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))

      stargazers_stub = stub_request(:get, subject.get_query_url(work) + "/stargazers").to_return(:body => File.read(fixture_path + 'github_stargazers.json'))
      body = File.read(fixture_path + 'github.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:total]).to eq(10)
      expect(event[:readers]).to eq(7)
      expect(event[:events_url]).to eq("https://github.com/ropensci/alm")
      expect(event[:extra]["stargazers_count"]).to eq(7)
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2013, month: 9, total: 7, readers: 7)

      related_work = response[:works].first
      expect(related_work['URL']).to eq("https://github.com/sckott")
      expect(related_work['author']).to eq([{"family"=>"Sckott", "given"=>""}])
      expect(related_work['title']).to eq("Github user sckott")
      expect(related_work['container-title']).to eq("Github")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 9, 5]])
      expect(related_work['type']).to eq("entry")
      expect(related_work["timestamp"]).to eq("2013-09-05T00:00:00Z")
      expect(related_work["related_works"]).to eq([{"related_work"=> work.pid, "source"=>"github", "relation_type"=>"bookmarks"}])
    end

    it "should catch timeout errors with the github API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for https://api.github.com/repos/ropensci/alm", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
