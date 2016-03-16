require 'rails_helper'

describe ScienceSeeker, type: :model, vcr: true do
  let(:work) { FactoryGirl.create(:work) }
  subject { FactoryGirl.create(:science_seeker) }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")
    end

    it "should get_provenance_url" do
      expect(subject.get_provenance_url(work_id: work.id)).to eq("http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=#{work.doi_escaped}")
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869")
      body = File.read(fixture_path + 'science_seeker.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the ScienceSeeker API" do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000001", doi: "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", :status=>408)
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
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events and event_count returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there is an incomplete response returned by the ScienceSeeker API" do
      body = File.read(fixture_path + 'science_seeker_incomplete.xml')
      result = Hash.from_xml(body)
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events and event_count returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(3)
      expect(response.first[:relation]).to eq("subj_id"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=10.1371%2Fjournal.pone.0035869",
                                              "source_id"=>"scienceseeker")

      expect(response.first[:subj]).to eq("pid"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                          "author"=>[{"given"=>"Duncan"}],
                                          "title"=>"Web analytics: Numbers speak louder than words",
                                          "container-title"=>"O'Really?",
                                          "issued"=>{"date-parts"=>[[2012, 5, 18]]},
                                          "timestamp"=>"2012-05-18T07:58:34Z",
                                          "URL"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should report if there is one event returned by the ScienceSeeker API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.0035869", published_on: "2012-05-03")
      body = File.read(fixture_path + 'science_seeker_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://scienceseeker.org/posts/?filter0=citation&modifier0=doi&value0=10.1371%2Fjournal.pone.0035869",
                                              "source_id"=>"scienceseeker")

      expect(response.first[:subj]).to eq("pid"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                          "author"=>[{"given"=>"Duncan"}],
                                          "title"=>"Web analytics: Numbers speak louder than words",
                                          "container-title"=>"O'Really?",
                                          "issued"=>{"date-parts"=>[[2012, 5, 18]]},
                                          "timestamp"=>"2012-05-18T07:58:34Z",
                                          "URL"=>"http://duncan.hull.name/2012/05/18/two-ton/",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should catch timeout errors with the ScienceSeeker API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://scienceseeker.org/search/default/?type=post&filter0=citation&modifier0=doi&value0=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
