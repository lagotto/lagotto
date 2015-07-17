require 'rails_helper'

describe DataoneUsage, type: :model, vcr: true do

  subject { FactoryGirl.create(:dataone_usage) }

  let(:work) { FactoryGirl.create(:work, dataone: "http://dx.doi.org/10.5061/dryad.6t94p?ver=2011-07-07T16:35:33.823-04:00", year: 2011, month: 7, day: 7) }

  context "get_data" do
    it "should report that there are no events if dataone is missing" do
      work = FactoryGirl.create(:work, :dataone => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the DataONE API" do
      work = FactoryGirl.create(:work, :dataone => "doi:10.5063/F1PC3085", published_on: "2014-09-22")
      response = subject.get_data(work)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are events returned by the DataONE API" do
      response = subject.get_data(work)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should catch timeout errors with the DataONE API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://cn.dataone.org/cn/v1/query/logsolr/select?facet.range.end=2015-07-17T23%3A59%3A59Z&facet.range.gap=%2B1MONTH&facet.range.start=2011-07-07T00%3A00%3A00Z&facet.range=dateLogged&facet=true&fq=event%3Aread&q=pid%3Ahttp%5C%3A%2F%2Fdx.doi.org%2F10.5061%2Fdryad.6t94p%3Fver%3D2011-07-07T16%5C%3A35%5C%3A33.823-04%5C%3A00+AND+isRepeatVisit%3Afalse+AND+inPartialRobotList%3Afalse&wt=json", status: 408)
      expect(stub).to have_been_requested
      expect(Alert.count).to eq(1)
      alert = Alert.first
      expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(alert.status).to eq(408)
      expect(alert.source_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if dataone is missing" do
      work = FactoryGirl.create(:work, dataone: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work)).to eq(events: { source: "dataone_usage", work: work.pid, total: 0, months: [] })
    end

    it "should report if there are no events returned by the DataONE API" do
      body = File.read(fixture_path + 'dataone_usage_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "dataone_usage", work: work.pid, total: 0,  months: [] })
    end

    it "should report if there are events returned by the DataONE API" do
            body = File.read(fixture_path + 'dataone_usage_raw.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(74)
      expect(response[:events][:months].length).to eq(11)
      expect(response[:events][:months].first).to eq(month: 9, year: 2014, total: 13)
      expect(response[:events][:events_url]).to be_nil
    end
  end
end
