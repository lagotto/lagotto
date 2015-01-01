require 'rails_helper'

describe F1000, type: :model, vcr: true do
  subject { FactoryGirl.create(:f1000) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  context "save f1000 data" do
    it "should fetch and save f1000 data" do
      # stub = stub_request(:get, subject.get_feed_url).to_return(:headers => { "Content-Type" => "application/xml" }, :body => File.read(fixture_path + 'f1000.xml'), :status => 200)
      # subject.get_feed.should be true
      # file = "#{Rails.root}/data/#{subject.filename}.xml"
      # File.exist?(file).should be true
      # stub.should have_been_requested
      # Alert.count.should == 0
    end
  end

  context "parse f1000 data" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
      body = File.read(fixture_path + 'f1000.xml')
      File.open("#{Rails.root}/data/#{subject.filename}", 'w') { |file| file.write(body) }
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should parse f1000 data" do
      expect(subject.parse_feed).not_to be_blank
      expect(Alert.count).to eq(0)
    end
  end

  context "get_data from the f1000 internal database" do
    before(:each) do
      subject.put_lagotto_data(subject.db_url)
    end

    after(:each) do
      subject.delete_lagotto_data(subject.db_url)
    end

    it "should report if there are no events and event_count returned by f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      body = File.read(fixture_path + 'f1000_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body, :status => [404])
      response = subject.get_data(work)
      expect(response).to eq(error: "not_found", status: 404)
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'f1000.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://127.0.0.1:5984/f1000_test/#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the f1000 internal database" do
    it "should report if there are no events and event_count returned by f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      result = { error: "not_found", status: 404 }
      response = subject.parse_data(result, work)
      expect(response).to eq(:events=>[], :events_by_day=>[], :events_by_month=>[], :event_count=>0, :events_url=>nil, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0})
    end

    it "should report if there are events and event_count returned by f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pbio.1001420")
      body = File.read(fixture_path + 'f1000.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(2)
      expect(response[:events_url]).to eq("http://f1000.com/prime/718293874")

      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(month: 4, year: 2014, total: 2)
      expect(response[:event_metrics]).to eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 2, total: 2)

      event = response[:events].last
      expect(event[:event]['classifications']).to eq(["confirmation", "good_for_teaching"])
    end

    it "should catch timeout errors with f1000" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://127.0.0.1:5984/f1000_test/", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
