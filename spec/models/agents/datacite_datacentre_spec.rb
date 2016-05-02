require 'rails_helper'

describe DataciteDatacentre, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:datacite_datacentre) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=0&facet=true&facet.field=datacentre_facet&facet.limit=-1&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(689)
    end
  end

  context "queue_jobs" do
    it "should report if there are publishers returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs
      expect(response).to eq(689)
    end
  end

  context "get_data" do
    it "should report if there are publishers returned by the Datacite Metadata Search API" do
      response = subject.get_data
      datacentre_facet = response.fetch("facet_counts", {}).fetch("facet_fields", {}).fetch('datacentre_facet', [])
      items = datacentre_facet.values_at(* datacentre_facet.each_index.select {|i| i.even?})
      expect(items.length).to eq(689)
      expect(items.first).to eq("ANDS.CENTRE-1 - Griffith University")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=*%3A*&start=0&rows=0&facet=true&facet.field=datacentre_facet&facet.limit=-1&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_datacentre.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(628)
      expect(response.first[:message_type]).to eq("publisher")
      expect(response.first[:relation]).to eq("subj_id"=>"ANDS.CENTRE-1",
                                              "source_id"=>"datacite_datacentre")
      expect(response.first[:subj]).to eq("name"=>"ANDS.CENTRE-1",
                                          "title"=>"Griffith University",
                                          "registration_agency_id"=>"datacite",
                                          "active"=>true)
    end
  end
end
