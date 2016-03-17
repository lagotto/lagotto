require 'rails_helper'

describe Researchblogging, type: :model do
  let(:work) { FactoryGirl.create(:work) }
  subject { FactoryGirl.create(:researchblogging) }

  context "urls" do
    it "should get_query_url" do
      expect(subject.get_query_url(work_id: work.id)).to eq("http://researchbloggingconnect.com/blogposts?count=100&article=doi:#{work.doi_escaped}")
    end

    it "should get_provenance_url" do
      expect(subject.get_provenance_url(work_id: work.id)).to eq("http://researchblogging.org/post-search/list?article=#{work.doi_escaped}")
    end
  end

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
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the ResearchBlogging API" do
      body = File.read(fixture_path + 'researchblogging_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2009-07-01")
      body = File.read(fixture_path + 'researchblogging.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(8)
      expect(response.first[:relation]).to eq("subj_id"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://researchblogging.org/post-search/list?article=10.1371%2Fjournal.pone.0035869",
                                              "source_id"=>"researchblogging")

      expect(response.first[:subj]).to eq("pid"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                          "author"=>[{"family"=>"Spoetnik", "given"=>"Laika"}],
                                          "title"=>"Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan",
                                          "container-title"=>"Laika's Medliblog",
                                          "issued"=>"2012-10-27T11:32:09Z",
                                          "URL"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should report if there is one event returned by the ResearchBlogging API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0035869", published_on: "2012-10-01")
      body = File.read(fixture_path + 'researchblogging_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://researchblogging.org/post-search/list?article=10.1371%2Fjournal.pone.0035869",
                                              "source_id"=>"researchblogging")

      expect(response.first[:subj]).to eq("pid"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                          "author"=>[{"family"=>"Spoetnik", "given"=>"Laika"}],
                                          "title"=>"Why Publishing in the NEJM is not the Best Guarantee that Something is True: a Response to Katan",
                                          "container-title"=>"Laika's Medliblog",
                                          "issued"=>"2012-10-27T11:32:09Z",
                                          "URL"=>"http://laikaspoetnik.wordpress.com/2012/10/27/why-publishing-in-the-nejm-is-not-the-best-guarantee-that-something-is-true-a-response-to-katan/",
                                          "type"=>"post",
                                          "tracked"=>true)
    end

    it "should catch timeout errors with the ResearchBlogging API" do
      result = [{ error: "the server responded with status 408 for http://researchbloggingconnect.com/blogposts?count=100&work=doi:#{work.doi_escaped}", status: 408 }]
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
