require 'rails_helper'

describe DataoneCounter, type: :model, vcr: true do

  subject { FactoryGirl.create(:dataone_counter) }

  let(:work) { FactoryGirl.create(:work, dataone: "http://dx.doi.org/10.5061/dryad.f1cb2?ver=2011-11-15T15:33:05.847-05:00") }

  context "get_data" do
    it "should report that there are no events if dataone is missing" do
      work = FactoryGirl.create(:work, :dataone => nil)
      expect(subject.get_data(work)).to eq({})
    end

    it "should report if there are no events returned by the DataONE API" do
      work = FactoryGirl.create(:work, :dataone => "http://dx.doi.org/10.5061/dryad.f1cb2/16?ver=2012-12-03T16:54:29.781-05:00")
      response = subject.get_data(work)
      expect(response).to eq(Hash.from_xml(body))
      expect(response['rest']['response']['results']['item']).to be_nil
      expect(stub).to have_been_requested
    end

    it "should report if there are events returned by the DataONE API" do
      response = subject.get_data(work)
      expect(response["rest"]["response"]["criteria"]).to eq("year"=>"all", "month"=>"all", "journal"=>"all", "doi"=>work.doi)
      expect(response["rest"]["response"]["results"]["total"]["total"]).to eq("5900")
      expect(response["rest"]["response"]["results"]["item"].length).to eq(67)
    end

    it "should catch timeout errors with the Counter API" do
      stub = stub_request(:get, subject.get_query_url(work)).to_return(:status => [408])
      response = subject.get_data(work, source_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for https://cn.dataone.org/cn/v1/query/logsolr/select?facet.range.end=2015-07-16T23%3A59%3A59Z&facet.range.gap=%2B1MONTH&facet.range.start=2014-07-16T00%3A00%3A00Z&facet.range=dateLogged&facet=true&fq=event%3Aread&q=pid%3A#{CGI.escape(work.dataone)}%3Fver%3D2011-11-15T15%3A33%3A05.847-05%3A00&wt=json", status: 408)
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
      expect(subject.parse_data(result, work)).to eq(events: { source: "dataone_counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are no events returned by the DataONE API" do
      body = File.read(fixture_path + 'dataone_counter_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response).to eq(events: { source: "dataone_counter", work: work.pid, pdf: 0, html: 0, total: 0, extra: [], months: [] })
    end

    it "should report if there are events returned by the DataONE API" do
            body = File.read(fixture_path + 'dataone_counter.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work)
      expect(response[:events][:total]).to eq(3387)
      expect(response[:events][:pdf]).to eq(447)
      expect(response[:events][:html]).to eq(2919)
      expect(response[:events][:extra].length).to eq(37)
      expect(response[:events][:months].length).to eq(37)
      expect(response[:events][:months].first).to eq(month: 1, year: 2010, html: 299, pdf: 90, total: 390)
      expect(response[:events][:events_url]).to be_nil
    end

    it "should catch timeout errors with the DataONE API" do
      result = { error: "the server responded with status 408 for http://example.org?doi=#{work.doi_escaped}", status: 408 }
      response = subject.parse_data(result, work)
      expect(response).to eq(result)
    end
  end
end
