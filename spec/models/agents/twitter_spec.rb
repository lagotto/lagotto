require 'rails_helper'

describe Twitter, type: :model, vcr: true do
  subject { FactoryGirl.create(:twitter) }

  let(:work) { FactoryGirl.create(:work, canonical_url: "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pmed.0020124", published_on: "2012-05-03") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Twitter API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the Twitter API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter_nil.json', encoding: 'UTF-8')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the Twitter API" do
      body = File.read(fixture_path + 'twitter.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(2)
      expect(response.first[:relation]).to eq("subj_id"=>"http://twitter.com/regrum/status/204270013081849857",
                                               "obj_id"=>work.pid,
                                               "relation_type_id"=>"discusses",
                                               "source_id"=>"twitter")

      expect(response.first[:subj]).to eq("pid"=>"http://twitter.com/regrum/status/204270013081849857",
                                          "author"=>[{"given"=>"regrum"}],
                                          "title"=>"Don't be blinded by science http://t.co/YOWRhsXb",
                                          "container-title"=>"Twitter",
                                          "issued"=>"2012-05-20T17:59:00Z",
                                          "URL"=>"http://twitter.com/regrum/status/204270013081849857",
                                          "type"=>"personal_communication",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"twitter")
    end

    it "should catch timeout errors with the Twitter API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
