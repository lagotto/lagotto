require 'rails_helper'

describe DataciteData, type: :model, vcr: true do
  subject { FactoryGirl.create(:datacite_data) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.5061/DRYAD.8515") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work)).to eq({})
    end

    # it "should report if there are no events and event_count returned by the Datacite API" do
    #   work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0043007")
    #   response = subject.get_data(work)
    #   expect(response["response"]["numFound"]).to eq(0)
    #   expect(response["response"]["docs"]).to be_empty
    # end

    # it "should report if there are events and event_count returned by the Datacite API" do
    #   response = subject.get_data(work)
    #   expect(response["response"]["numFound"]).to eq(1)
    #   doc = response["response"]["docs"].first
    #   expect(doc["doi"]).to eq("10.5061/DRYAD.8515")
    # end

    it "should catch timeout errors with the Datacite API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, options = { :source_id => subject.id })
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=doi:#{work.doi_escaped}&fl=doi,relatedIdentifier&fq=is_active:true&fq=has_metadata:true&rows=1000&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "datacite_data", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are no events and event_count returned by the Datacite API" do
      body = File.read(fixture_path + 'datacite_data_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(works: [], events: { source: "datacite_data", work: work.pid, total: 0, days: [], months: [] })
    end

    it "should report if there are events and event_count returned by the Datacite API" do
      relation_type = FactoryGirl.create(:relation_type, inverse_name: "has_part", inverse_title: "Has part", name: "is_part_of", title: "Is part of")
      body = File.read(fixture_path + 'datacite_data.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:works].length).to eq(3)
      expect(response[:events][:total]).to eq(3)
      expect(response[:events][:events_url]).to eq("http://search.datacite.org/ui?q=doi:#{work.doi_escaped}")

      event = response[:works].first
      expect(event["DOI"]).to eq("10.5061/dryad.8515/1")
      expect(event['author']).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"}, {"family"=>"Durand", "given"=>"Patrick"}, {"family"=>"Prugnolle", "given"=>"Franck"}, {"family"=>"Douzery", "given"=>"Emmanuel J. P."}, {"family"=>"Arnathau", "given"=>"Céline"}, {"family"=>"Nkoghe", "given"=>"Dieudonné"}, {"family"=>"Leroy", "given"=>"Eric"}, {"family"=>"Renaud", "given"=>"François"}])
      expect(event['title']).to eq("Ollomo_PLoSPathog_2009")
      expect(event['container-title']).to be_nil
      expect(event['issued']).to eq("date-parts"=>[[2011]])
      expect(event['type']).to eq("dataset")
      expect(event['related_works']).to eq([{"related_work"=>work.pid, "source"=>"datacite_data", "relation_type"=>"is_part_of"}])
    end

    it "should catch timeout errors with the Datacite API" do
      result = { error: "the server responded with status 408 for http://search.datacite.org/api?q=doi:#{work.doi_escaped}&fl=relatedIdentifier,doi,creator,title,publisher,publicationYear&fq=is_active:true&fq=has_metadata:true&indent=true&rows=100&wt=json", status: 408 }
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
