require 'rails_helper'

describe PlosComments, type: :model, vcr: true do
  subject { FactoryGirl.create(:plos_comments) }

  let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.pone.0067729") }

  context "use the PLOS comments API" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, doi: "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report that there are no events if the doi is for PLOS Currents" do
      work = FactoryGirl.build(:work, :doi => "10.1371/currents.md.411a8332d61e22725e6937b97e6d0ef8")
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if the work was not found by the PLOS comments API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pone.008109x")
      response = subject.get_data(work)
      expect(response).to eq(error: "Item not found at the provided ID: info:doi/10.1371/journal.pone.008109x\n", status: 404)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      response = subject.get_data(work)
      expect(response).to eq('data' => [])
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      work = FactoryGirl.build(:work, :doi => "10.1371/journal.pmed.0020124")
      response = subject.get_data(work)
      expect(response["data"].length).to eq(31)
      data = response["data"].first
      expect(data["title"]).to eq("Open Access and the Skewness of Science: It Can't Be Cream All the Way Down")
    end

    it "should catch timeout errors with the PLOS comments API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(status: [408])
      response = subject.get_data(work, options = { :agent_id => subject.id })
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
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "plos_comments", work_id: work.pid, discussed: 0, total: 0, extra: [], events_url: nil, days: [], months: [] }])
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "plos_comments", work_id: work.pid, discussed: 0, total: 0, extra: [], events_url: nil, days: [], months: [] }])
    end

    it "should report if the work was not found by the PLOS comments API" do
      result = { error: File.read(fixture_path + 'plos_comments_error.txt') }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      result = { 'data' => JSON.parse(body) }
      expect(subject.parse_data(result, work)).to eq(works: [], events: [{ source_id: "plos_comments", work_id: work.pid, discussed: 0, total: 0, extra: [], events_url: nil, days: [], months: [] }])
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pmed.0020124", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_comments.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work)

      event = response[:events].first
      expect(event[:total]).to eq(36)
      expect(event[:days].length).to eq(2)
      expect(event[:days].first).to eq(year: 2009, month: 3, day: 30, total: 7)
      expect(event[:months].length).to eq(9)
      expect(event[:months].first).to eq(year: 2009, month: 3, total: 21)

      expect(response[:works].length).to eq(31)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Samigulina", "given"=>"Gulnara"}])
      expect(related_work['title']).to eq("A small group research.")
      expect(related_work['container-title']).to eq("PLOS Comments")
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 10, 27]])
      expect(related_work['type']).to eq("personal_communication")
      expect(related_work['URL']).to eq("http://dx.doi.org/#{work.doi}")
      expect(related_work['related_works']).to eq([{"related_work"=> work.pid, "source"=>"plos_comments", "relation_type"=>"discusses"}])
    end

    it "should catch timeout errors with the PLOS comments API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "http://api.plosjournals.org/v1/articles/#{work.doi}?comments", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
