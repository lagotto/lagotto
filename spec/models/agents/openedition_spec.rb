require 'rails_helper'

describe Openedition, type: :model, vcr: true do
  subject { FactoryGirl.create(:openedition) }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the Openedition API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      response = subject.get_data(work_id: work.id)
      expect(response["RDF"]["item"]).to be_nil
    end

    it "should report if there are events returned by the Openedition API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      response = subject.get_data(work_id: work.id)
      expect(response["RDF"]["item"]).to eq("link"=>"http://ruedesfacs.hypotheses.org/?p=1666", "title"=>"Saartjie Baartman : la Vénus Hottentote", "date"=>"2013-05-27", "creator"=>"ruedesfacs", "isPartOf"=>"Rue des facs", "description"=>"\n\n ... , no 3 (1 septembre 2000): 606 607. doi:<em>10.2307</em>/<em>683422</em>. « The Hottentot Venus Is Going Home ». The Journal of Blacks in Higher Education no 35 (1 avril 2002): 63. doi:<em>10.2307</em>/3133845. Vous trouverez toutes\n ... \n\n", "about"=>"http://ruedesfacs.hypotheses.org/?p=1666")
    end

    it "should catch errors with the Openedition API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work.id, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.source_id).to eq(subject.source_id)
    end
  end

  context "parse_data" do
    let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001") }

    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the Openedition API" do
      body = File.read(fixture_path + 'openedition_nil.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the Openedition API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422", published_on: "2013-05-03")
      body = File.read(fixture_path + 'openedition.xml')
      result = Hash.from_xml(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:relation]).to eq("subj_id"=>"http://ruedesfacs.hypotheses.org/?p=1666",
                                              "obj_id"=>work.pid,
                                              "relation_type_id"=>"discusses",
                                              "provenance_url"=>"http://search.openedition.org/index.php?op[]=AND&q[]=10.2307%2F683422&field[]=All&pf=Hypotheses.org",
                                              "source_id"=>"openedition")

      expect(response.first[:subj]).to eq("pid"=>"http://ruedesfacs.hypotheses.org/?p=1666",
                                          "author"=>[{"given"=>"ruedesfacs"}],
                                          "title"=>"Saartjie Baartman : la Vénus Hottentote",
                                          "container-title"=>nil,
                                          "issued"=>"2013-05-27T00:00:00Z",
                                          "URL"=>"http://ruedesfacs.hypotheses.org/?p=1666",
                                          "type"=>"post",
                                          "tracked"=>false)
    end

    it "should catch timeout errors with the OpenEdition API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
