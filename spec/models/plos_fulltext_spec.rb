require 'rails_helper'

describe PlosFulltext, type: :model, vcr: true do
  subject { FactoryGirl.create(:plos_fulltext) }

  let(:work) { FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules") }

  context "lookup canonical URL" do
    it "should look up canonical URL if there is no work url" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007", :canonical_url => nil)
      response = subject.get_data(work_id: work.id)
    end

    it "should not look up canonical URL if there is work url" do
      #lookup_stub = stub_request(:get, work.canonical_url).to_return(:status => 200, :headers => { 'Location' => work.canonical_url })
      #stub = stub_request(:get, subject.get_query_url(work)).to_return(:body => File.read(fixture_path + 'plos_fulltext.json'))
      response = subject.get_data(work_id: work.id)
      #expect(lookup_stub).not_to have_been_requested
      #expect(stub).to have_been_requested
    end
  end

  context "get_data" do
    it "should report that there are no events if the doi and canonical_url are missing" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the PLOS Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/pymor/pymor")
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are events returned by the PLOS Search API" do
      response = subject.get_data(work_id: work.id)
      expect(response["response"]["numFound"]).to eq(1)
      doc = response["response"]["docs"].first
      expect(doc["id"]).to eq("10.1371/journal.pcbi.1003833")
    end

    it "should catch errors with the PLOS Search API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work_id: work, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?q=#{subject.get_query_string(work)}&fq=doc_type:full&fl=id,publication_date,title,cross_published_journal_name,author_display&wt=json&rows=1000", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
     it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, doi: "10.1371/journal.pmed.0020124")
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "plos_fulltext", work_id: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are no events returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_fulltext_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq(works: [], events: [{ source_id: "plos_fulltext", work_id: work.pid, total: 0, events_url: nil, extra: [], days: [], months: [] }])
    end

    it "should report if there are events returned by the PLOS Search API" do
      work = FactoryGirl.create(:work, doi: nil, canonical_url: "https://github.com/rougier/ten-rules", published_on: "2009-03-15")
      body = File.read(fixture_path + 'plos_fulltext.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      event = response[:events].first
      expect(event[:source_id]).to eq("plos_fulltext")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)
      expect(event[:days]).to be_empty
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2014, month: 9, total: 1)

      expect(response[:works].length).to eq(1)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Rougier", "given"=>"Nicolas P."}, {"family"=>"Droettboom", "given"=>"Michael"}, {"family"=>"Bourne", "given"=>"Philip E."}])
      expect(related_work['title']).to eq("Ten Simple Rules for Better Figures")
      expect(related_work['container-title']).to eq("PLOS Computational Biology")
      expect(related_work['issued']).to eq("date-parts"=>[[2014, 9, 11]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['timestamp']).to eq("2014-09-11T00:00:00Z")
      expect(related_work['related_works']).to eq([{"related_work"=> work.pid, "source"=>"plos_fulltext", "relation_type"=>"cites"}])

      extra = event[:extra].last
      expect(extra[:event_time]).to eq("2014-09-11T00:00:00Z")
      expect(extra[:event_csl]['author']).to eq([{"family"=>"Rougier", "given"=>"Nicolas P."}, {"family"=>"Droettboom", "given"=>"Michael"}, {"family"=>"Bourne", "given"=>"Philip E."}])
      expect(extra[:event_csl]['title']).to eq("Ten Simple Rules for Better Figures")
      expect(extra[:event_csl]['container-title']).to eq("PLOS Computational Biology")
      expect(extra[:event_csl]['issued']).to eq("date-parts"=>[[2014, 9, 11]])
      expect(extra[:event_csl]['type']).to eq("article-journal")
    end

    it "should catch timeout errors with the PLOS Search API" do
      result = { error: "the server responded with status 408 for http://example.org?doi={doi}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
