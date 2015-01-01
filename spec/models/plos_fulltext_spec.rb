require 'rails_helper'

describe PlosFulltext, :type => :model do
  subject { FactoryGirl.create(:plos_fulltext) }

  let(:work) { FactoryGirl.build(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      lookup_stub = stub_request(:get, work.doi_as_url).to_return(:status => 404)
      response = subject.get_data(work)
      expect(lookup_stub).to have_been_requested
    end

    it "should not look up canonical URL if there is work url" do
      lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'plos_fulltext.json'))
      response = subject.get_data(work)
      expect(lookup_stub).not_to have_been_requested
      expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_fulltext_nil.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_fulltext.json')
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => body)
      response = subject.get_data(work)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch errors with the PLOS Search API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?q=#{subject.get_query_string(work)}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    let(:null_response) { { :events=>[], :events_by_day=>[], :events_by_month=>[], :events_url=>nil, :event_count=>0, :event_metrics=>{:pdf=>nil, :html=>nil, :shares=>nil, :groups=>nil, :comments=>nil, :likes=>nil, :citations=>0, :total=>0 } } }

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.build(:work, doi: "10.1371/journal.pmed.0020124")
      result = {}
      expect(subject.parse_data(result, work)).to eq({})
    end

    it "should report if there are no events and event_count returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work)).to eq(null_response)
    end

    it "should report if there are events and event_count returned by the PLOS Search API" do
      work = FactoryGirl.build(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work)
      expect(response[:event_count]).to eq(1)
      expect(response[:event_metrics]).to eq(pdf: nil, html: nil, shares: nil, groups: nil, comments: nil, likes: nil, citations: 1, total: 1)

      expect(response[:events_by_day]).to be_empty
      expect(response[:events_by_month].length).to eq(1)
      expect(response[:events_by_month].first).to eq(year: 2014, month: 9, total: 1)

      event = response[:events].last

      expect(event[:event_csl]['author']).to eq([{"family"=>"Rougier", "given"=>"Nicolas P."}, {"family"=>"Droettboom", "given"=>"Michael"}, {"family"=>"Bourne", "given"=>"Philip E."}])
      expect(event[:event_csl]['title']).to eq("Ten Simple Rules for Better Figures")
      expect(event[:event_csl]['container-title']).to eq("PLOS Computational Biology")
      expect(event[:event_csl]['issued']).to eq("date-parts"=>[[2014, 9, 11]])
      expect(event[:event_csl]['type']).to eq("article-journal")
      expect(event[:event_csl]['url']).to eq("http://dx.doi.org/10.1371/journal.pcbi.1003833")

      expect(event[:event_time]).to eq("2014-09-11T00:00:00Z")
    end

    it "should catch timeout errors with the PLOS Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
