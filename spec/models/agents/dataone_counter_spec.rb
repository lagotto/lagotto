require 'rails_helper'

describe DataoneCounter, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 7, 19)) }

  subject { FactoryGirl.create(:dataone_counter) }

  let(:work) { FactoryGirl.create(:work, dataone: "http://dx.doi.org/10.5061/dryad.6t94p?ver=2011-07-07T16:35:33.823-04:00", year: 2011, month: 7, day: 7) }

  context "get_data" do
    it "should report that there are no events if dataone is missing" do
      work = FactoryGirl.create(:work, :dataone => nil)
      expect(subject.get_data(work_id: work)).to eq({})
    end

    it "should report if there are no events returned by the DataONE API" do
      work = FactoryGirl.create(:work, :dataone => "doi:10.5063/F1PC3085", published_on: "2014-09-22")
      response = subject.get_data(work_id: work)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are events returned by the DataONE API" do
      response = subject.get_data(work_id: work)
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should catch timeout errors with the DataONE API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for https://cn.dataone.org/cn/v1/query/logsolr/select?facet.range.end=2015-07-19T23%3A59%3A59Z&facet.range.gap=%2B1MONTH&facet.range.start=2011-07-07T00%3A00%3A00Z&facet.range=dateLogged&facet=true&fq=event%3Aread&q=pid%3Ahttp%5C%3A%2F%2Fdx.doi.org%2F10.5061%2Fdryad.6t94p%3Fver%3D2011-07-07T16%5C%3A35%5C%3A33.823-04%5C%3A00+AND+isRepeatVisit%3Afalse+AND+inFullRobotList%3Afalse&wt=json", status: 408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if dataone is missing" do
      work = FactoryGirl.create(:work, dataone: nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the DataONE API" do
      body = File.read(fixture_path + 'dataone_usage_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([])
    end

    it "should report if there are events returned by the DataONE API" do
      body = File.read(fixture_path + 'dataone_usage_raw.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"https://www.dataone.org",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"downloads",
                                              "total"=>74,
                                              "source_id"=>"dataone_counter")
    end
  end
end
