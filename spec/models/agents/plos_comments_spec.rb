require 'rails_helper'

describe PlosComments, type: :model do
  subject { FactoryGirl.create(:plos_comments) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0067729") }

  context "use the PLOS comments API" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, doi: "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the doi is for PLOS Currents" do
      work = FactoryGirl.create(:work, :doi => "10.1371/currents.md.411a8332d61e22725e6937b97e6d0ef8")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if the work was not found by the PLOS comments API" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pone.008109x")
      body = File.read(fixture_path + 'plos_comments_error.txt')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body, status: [404])
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(error: "Item not found at the provided ID: info:doi/10.1371/journal.pone.008109x\n", status: 404)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq('data' => [])
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pmed.0020124")
      body = File.read(fixture_path + 'plos_comments.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)
      response = subject.get_data(work_id: work.id)
      expect(response["data"].length).to eq(31)
      data = response["data"].first
      expect(data["title"]).to eq("Open Access and the Skewness of Science: It Can't Be Cream All the Way Down")
    end

    it "should catch timeout errors with the PLOS comments API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(status: [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.plosjournals.org/v1/articles/#{work.doi}?comments=", status: 408)
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
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if the work was not found by the PLOS comments API" do
      result = { error: File.read(fixture_path + 'plos_comments_error.txt') }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      result = { 'data' => JSON.parse(body) }
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pmed.0020124", doi: "10.1371/journal.pmed.0020124", canonical_url: "http://journals.plos.org/plosmedicine/article?id=10.1371%2Fjournal.pmed.0020124", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_comments.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(31)
      expect(response.first[:relation]).to eq("subj_id"=>"http://journals.plos.org/plosmedicine/article/comment?id=info%3Adoi%2F10.1371%2Fannotation%2F177a9a89-9723-45a3-aac1-d27ca9deb664",
                                              "obj_id"=>"http://doi.org/10.1371/journal.pmed.0020124",
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://journals.plos.org/plosmedicine/article/comments?id=10.1371%2Fjournal.pmed.0020124",
                                              "source_id"=>"plos_comments")

      expect(response.first[:subj]).to eq("pid"=>"http://journals.plos.org/plosmedicine/article/comment?id=info%3Adoi%2F10.1371%2Fannotation%2F177a9a89-9723-45a3-aac1-d27ca9deb664",
                                          "author"=>[{"family"=>"Staff", "given"=>"PLoS Medicine"}],
                                          "title"=>"Open Access and the Skewness of Science: It Can't Be Cream All the Way Down",
                                          "container-title"=>"PLOS Comments",
                                          "issued"=>"2009-03-31T00:31:12Z",
                                          "URL"=>"http://journals.plos.org/plosmedicine/article/comment?id=info%3Adoi%2F10.1371%2Fannotation%2F177a9a89-9723-45a3-aac1-d27ca9deb664",
                                          "type"=>"personal_communication",
                                          "tracked"=>false)
    end

    it "should catch timeout errors with the PLOS comments API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "http://api.plosjournals.org/v1/articles/#{work.doi}?comments", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
