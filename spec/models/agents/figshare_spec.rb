require 'rails_helper'

describe Figshare, type: :model, vcr: true do
  subject { FactoryGirl.create(:figshare) }

  let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0067729") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the figshare API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq(:error=>"the server responded with status 400 for http://api.figshare.com/v1/publishers/search_for?doi=10.1371/journal.pone.0116034", :status=>400)
    end

    it "should report if there are events returned by the figshare API" do
      response = subject.get_data(work_id: work.id)
      expect(response["count"]).to eq(6)
      item = response["items"].first
      expect(item["title"]).to eq("Genetic distances among the <i>Physolychnis a</i>- and <i>b-</i>copies.")
    end

    it "should catch timeout errors with the figshare API" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.figshare.com/v1/publishers/search_for?doi=#{work.doi}", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.source_id).to eq(subject.source_id)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report that there are no events if the doi has the wrong prefix" do
      work = FactoryGirl.create(:work, :doi => "10.5194/acp-12-12021-2012")
      result = {}
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the figshare API" do
      body = File.read(fixture_path + 'figshare_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the figshare API" do
      body = File.read(fixture_path + 'figshare.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(2)
      expect(response.first[:relation]).to eq("subj_id"=>"https://figshare.com",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"downloads",
                                              "total"=>1,
                                              "source_id"=>"figshare")
      expect(response.last[:relation]).to eq("subj_id"=>"https://figshare.com",
                                             "obj_id"=>work.pid,
                                             "relation_type_id"=>"views",
                                             "total"=>13,
                                             "source_id"=>"figshare")
    end

    it "should catch timeout errors with the figshare API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      result = { error: "the server responded with status 408 for http://api.figshare.com/v1/publishers/search_for?doi=#{work.doi}", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
