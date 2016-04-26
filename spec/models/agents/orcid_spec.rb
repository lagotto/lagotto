require 'rails_helper'

describe Orcid, type: :model, vcr: true do
  subject { FactoryGirl.create(:orcid) }

  let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0018011", published_on: "2009-09-01") }

  context "get_data" do
    it "should report that there are no events if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      expect(subject.get_data(work_id: work.id)).to eq({})
    end

    it "should report if there are no events returned by the ORCID API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0044294")
      response = subject.get_data(work_id: work.id)
      expect(response).to eq("message-version"=>"1.2", "orcid-profile"=>nil, "orcid-search-results"=>{"orcid-search-result"=>[], "num-found"=>0}, "error-desc"=>nil)
    end

    it "should report if there are events returned by the ORCID API" do
      response = subject.get_data(work_id: work.id)
      expect(response["orcid-search-results"]["num-found"]).to eq(1)
      profile = response["orcid-search-results"]["orcid-search-result"].first
      expect(profile["orcid-profile"]["orcid-identifier"]["uri"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "should catch timeout errors with the ORCID API" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000001")
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      response = subject.get_data(work_id: work, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://pub.orcid.org/v1.2/search/orcid-bio/?q=digital-object-ids:\"#{work.doi_escaped}\"&rows=100", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if the doi is missing" do
      work = FactoryGirl.create(:work, :doi => nil)
      result = {}
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are no events returned by the ORCID API" do
      body = File.read(fixture_path + 'orcid_nil.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      expect(subject.parse_data(result, work_id: work.id)).to eq([])
    end

    it "should report if there are events returned by the ORCID API" do
      allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5))

      body = File.read(fixture_path + 'orcid.json')
      result = JSON.parse(body)
      result.extend Hashie::Extensions::DeepFetch
      response = subject.parse_data(result, work_id: work.id)

      expect(response.length).to eq(1)
      expect(response.first[:contribution]).to eq("subj_id"=>"http://orcid.org/0000-0002-0159-2197",
                                                  "obj_id"=>work.pid,
                                                  "source_id"=>"orcid")

      expect(response.first[:subj]).to eq("pid"=>"http://orcid.org/0000-0002-0159-2197",
                                          "author"=>[{"family"=>"Eisen", "given"=>"Jonathan A."}],
                                          "title"=>"ORCID profile for Jonathan A. Eisen",
                                          "container-title"=>"ORCID Registry",
                                          "issued"=>"2013-09-05T00:00:00Z",
                                          "URL"=>"http://orcid.org/0000-0002-0159-2197",
                                          "type"=>"entry",
                                          "tracked"=>false,
                                          "registration_agency_id"=>"orcid")
    end

    it "should catch timeout errors with the ORCID API" do
      work = FactoryGirl.create(:work, :doi => "10.2307/683422")
      result = { error: "the server responded with status 408 for http://search.openedition.org/feed.php?op[]=AND&q[]=#{work.doi_escaped}&field[]=All&pf=Hypotheses.org", status: 408 }
      response = subject.parse_data(result, work_id: work.id)
      expect(response).to eq([result])
    end
  end
end
