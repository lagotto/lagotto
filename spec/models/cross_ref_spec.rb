require 'rails_helper'

describe CrossRef, :type => :model do
  subject { FactoryGirl.create(:crossref) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => "http://www.plosone.org/work/info%3Adoi%2F10.1371%2Fjournal.pone.0043007", :publisher_id => 340) }

  it "should report that there are no events if the doi is missing" do
    work = FactoryGirl.build(:work, :doi => nil)
    expect(subject.get_data(work)).to eq({})
  end

  it "should report that there are no events if work was published on the same day" do
    work = FactoryGirl.build(:work, :published_on => Time.zone.today)
    expect(subject.get_data(work)).to eq({})
  end

  context "publisher_configs" do
    it "all publisher_configs" do
      config = subject.publisher_configs.first[1]
      expect(config.username).to eq("username")
      expect(config.password).to eq("password")
    end

    it "for specific publisher" do
      config = subject.publisher_config(work.publisher_id)
      expect(config.username).to eq("username")
      expect(config.password).to eq("password")
    end
  end

  context "get_query_url" do
    it "with username and password" do
      expect(subject.get_query_url(work)).to eq("http://doi.crossref.org/servlet/getForwardLinks?usr=username&pwd=password&doi=10.1371%2Fjournal.pone.0043007")
    end

    it "without password" do
      crossref = FactoryGirl.create(:crossref_without_password)
      expect(crossref.get_query_url(work)).to be_nil
    end

    it "without publisher" do
      work = FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil)
      expect(subject.get_query_url(work)).to eq("http://www.crossref.org/openurl/?pid=openurl_username&id=doi:10.1007%2Fs00248-010-9734-2&noredirect=true")
    end
  end

  context "get_data from the CrossRef API" do
    it "should report if there are no events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      url = subject.get_query_url(work)
      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the CrossRef API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://doi.crossref.org/servlet/getForwardLinks?usr=username&pwd=password&doi=#{work.doi_escaped}", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "use the CrossRef OpenURL API" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil) }
    let(:url) { url = subject.get_query_url(work) }

    it "should use the OpenURL API" do
      expect(url).to eq("http://www.crossref.org/openurl/?pid=openurl_username&id=doi:#{work.doi_escaped}&noredirect=true")
    end

    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')

      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      stub = stub_request(:get, url).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the CrossRef OpenURL API" do
      stub = stub_request(:get, url).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=openurl_username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data from the CrossRef API" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 } } }

    it "should report if the doi is missing" do
      work = FactoryGirl.build(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are no events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(31)
      expect(response[:event_count]).to eq(31)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://dx.doi.org/#{event[:event]['doi']}")

      expect(event[:event_csl]['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(event[:event_csl]['title']).to eq("Audiotactile Interactions In Temporal Perception")
      expect(event[:event_csl]['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[["2011"]])
      expect(event[:event_csl]['type']).to eq("article-journal")
    end

    it "should report if there is one event returned by the CrossRef API" do
      body = File.read(fixture_path + 'cross_ref_one.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events].length).to eq(1)
      expect(response[:event_count]).to eq(1)
      event = response[:events].first
      expect(event[:event_url]).to eq("http://dx.doi.org/#{event[:event]['doi']}")

      expect(event[:event_csl]['author']).to eq([{"family"=>"Occelli", "given"=>"Valeria"}, {"family"=>"Spence", "given"=>"Charles"}, {"family"=>"Zampini", "given"=>"Massimiliano"}])
      expect(event[:event_csl]['title']).to eq("Audiotactile Interactions In Temporal Perception")
      expect(event[:event_csl]['container-title']).to eq("Psychonomic Bulletin & Review")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[["2011"]])
      expect(event[:event_csl]['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the CrossRef API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", :status=>408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end

  context "parse_data from the CrossRef OpenURL API" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1007/s00248-010-9734-2", canonical_url: "http://link.springer.com/work/10.1007%2Fs00248-010-9734-2#page-1", publisher_id: nil) }
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 } } }

    it "should report if the doi is missing" do
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there is an event_count of zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(null_response)
    end

    it "should report if there is an event_count greater than zero returned by the CrossRef OpenURL API" do
      body = File.read(fixture_path + 'cross_ref_openurl.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(13)
    end

    it "should catch timeout errors with the CrossRef OpenURL API" do
      result = { error: "the server responded with status 408 for http://www.crossref.org/openurl/?pid=username&id=doi:#{work.doi_escaped}&noredirect=true", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
