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
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://api.plosjournals.org/v1/articles/#{work.doi}?comments=", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>0, :likes=>nil, :citations=>nil, :total=>0 }, :extra=>nil } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if the work was not found by the PLOS comments API" do
      result = { error: File.read(fixture_path + 'plos_comments_error.txt') }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end

    it "should report if there are no events and event_count returned by the PLOS comments API" do
      body = File.read(fixture_path + 'plos_comments_nil.json')
      result = { 'data' => JSON.parse(body) }
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the PLOS comments API" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pmed.0020124", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_comments.json')
      result = { 'data' => JSON.parse(body) }
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(31)
      expect(response[:event_metrics]).to eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: 31, likes: nil, citations: nil, total: 31)

      expect(response[:events_by_day].length).to eq(2)
      expect(response[:events_by_day].first).to eq(year: 2009, month: 3, day: 30, total: 7)
      expect(response[:events_by_month].length).to eq(9)
      expect(response[:events_by_month].first).to eq(year: 2009, month: 3, total: 21)

      event = response[:events].last
      expect(event['author']).to eq([{"family"=>"Samigulina", "given"=>"Gulnara"}])
      expect(event['title']).to eq("A small group research.")
      expect(event['container-title']).to eq("PLOS Comments")
      expect(event['issued']).to eq("date-parts"=>[[2013, 10, 27]])
      expect(event['type']).to eq("personal_communication")
      expect(event['URL']).to eq("http://dx.doi.org/#{work.doi}")
    end

    it "should catch timeout errors with the PLOS comments API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "http://api.plosjournals.org/v1/articles/#{work.doi}?comments", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
