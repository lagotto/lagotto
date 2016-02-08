require 'rails_helper'

describe Scopus, type: :model do
  subject { FactoryGirl.create(:scopus) }

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pmed.0030442", doi: "10.1371/journal.pmed.0030442", scp: nil) }

  context "get_data" do
    it "should report that there are no events if the DOI is missing" do
      work = FactoryGirl.create(:work, :doi => "")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events and event_count returned by the Scopus API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.000001")
      body = File.read(fixture_path + 'scopus_nil.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should report if there are events and event_count returned by the Scopus API" do
      body = File.read(fixture_path + 'scopus.json')
      events = JSON.parse(body)["search-results"]["entry"][0]
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).with(:headers => { 'Accept'=>'application/json', 'User-Agent'=>"Lagotto - http://#{ENV['SERVERNAME']}", 'X-ELS-APIKEY' => subject.api_key, 'X-ELS-INSTTOKEN' => subject.insttoken }).to_return(:headers => { "Content-Type" => "application/json" }, :body => body, :status => 200)
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(JSON.parse(body))
      expect(stub).to have_been_requested
    end

    it "should catch timeout errors with the Scopus API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end

    context "parse_data" do
      it "should report if the doi is missing" do
        result = {}
        result.extend Hashie::Extensions::DeepFetch
        expect(subject.parse_data(result, work_id: work.id)).to eq(events: [{ source_id: "scopus", work_id: work.pid, total: 0, events_url: nil, extra: {} }])
      end

      it "should report if there are no events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus_nil.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.000001")
        response = subject.parse_data(result, work_id: work.id)
        expect(response).to eq(events: [{ source_id: "scopus", work_id: work.pid, total: 0, events_url: nil, extra: { "@force-array"=>"true", "error"=>"Result set was empty" } }])
      end

      it "should report if there are events and event_count returned by the Scopus API" do
        body = File.read(fixture_path + 'scopus.json')
        result = JSON.parse(body)
        result.extend Hashie::Extensions::DeepFetch
        events = JSON.parse(body)["search-results"]["entry"][0]
        response = subject.parse_data(result, work_id: work.id)

        event = response[:events].first
        expect(event[:source_id]).to eq("scopus")
        expect(event[:work_id]).to eq(work.pid)
        expect(event[:total]).to eq(1814)
        expect(event[:events_url]).to eq("http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724")
        expect(event[:total]).to eq(1814)
        expect(event[:extra]).to eq("@_fa"=>"true", "link"=>[{"@_fa"=>"true", "@ref"=>"self", "@href"=>"http://api.elsevier.com/content/abstract/scopus_id:33845338724"}, {"@_fa"=>"true", "@ref"=>"scopus", "@href"=>"http://www.scopus.com/inward/record.url?partnerID=HzOxMe3b&scp=33845338724"}, {"@_fa"=>"true", "@ref"=>"scopus-citedby", "@href"=>"http://www.scopus.com/inward/citedby.url?partnerID=HzOxMe3b&scp=33845338724"}], "prism:url"=>"http://api.elsevier.com/content/abstract/scopus_id:33845338724", "dc:identifier"=>"SCOPUS_ID:33845338724", "eid"=>"2-s2.0-33845338724", "dc:title"=>"Projections of global mortality and burden of disease from 2002 to 2030", "dc:creator"=>"Mathers, C.D.", "prism:publicationName"=>"PLoS Medicine", "prism:issn"=>"15491277", "prism:eIssn"=>"15491676", "prism:volume"=>"3", "prism:issueIdentifier"=>"11", "prism:pageRange"=>"2011-2030", "prism:coverDate"=>"2006-11-01", "prism:coverDisplayDate"=>"November 2006", "prism:doi"=>"10.1371/journal.pmed.0030442", "citedby-count"=>"1814", "affiliation"=>[{"@_fa"=>"true", "affilname"=>"Organisation Mondiale de la Santé", "affiliation-city"=>"Geneve", "affiliation-country"=>"Switzerland"}], "pubmed-id"=>"17132052", "prism:aggregationType"=>"Journal", "subtype"=>"ar", "subtypeDescription"=>"Article")
        expect(work.scp).to eq("33845338724")
      end

      it "should catch timeout errors with the Scopus API" do
        work = FactoryGirl.create(:work, :doi => "10.2307/683422")
        result = { error: "the server responded with status 408 for https://api.elsevier.com/content/search/index:SCOPUS?query=DOI(#{work.doi_escaped})", status: 408 }
        response = subject.parse_data(result, work_id: work.id)
        expect(response).to eq(result)
      end
    end
  end
end
