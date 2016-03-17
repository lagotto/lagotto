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
      response = subject.get_data(work_id: work.id, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
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

      event = response[:events].first
      expect(event[:source_id]).to eq("openedition")
      expect(event[:work_id]).to eq(work.pid)
      expect(event[:total]).to eq(1)
      expect(event[:events_url]).to eq("http://search.openedition.org/index.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org")
      expect(event[:months].length).to eq(1)
      expect(event[:months].first).to eq(year: 2013, month: 5, total: 1)

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work['URL']).to eq("http://ruedesfacs.hypotheses.org/?p=1666")
      expect(related_work['author']).to eq([{"family"=>"Ruedesfacs", "given"=>""}])
      expect(related_work['title']).to eq("Saartjie Baartman : la Vénus Hottentote")
      expect(related_work['container-title']).to be_nil
      expect(related_work['issued']).to eq("date-parts"=>[[2013, 5, 27]])
      expect(related_work['timestamp']).to eq("2013-05-27T00:00:00Z")
      expect(related_work['type']).to eq("post")
      expect(related_work['related_works']).to eq([{"related_work"=>"http://doi.org/10.2307/683422", "source_id"=>"openedition", "relation_type_id"=>"discusses"}])
    end

    it "should catch timeout errors with the OpenEdition APi" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = [{ error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", status: 408 }]
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq(result)
    end
  end
end
