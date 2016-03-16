require 'rails_helper'

describe PlosImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:plos_import) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=publication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=publication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=0&start=0&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=publication_date%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=1000&start=0&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(466)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2015-04-05", until_date: "2015-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the PLOS Search API" do
      response = subject.queue_jobs(from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the PLOS Search API" do
      response = subject.queue_jobs
      expect(response).to eq(466)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the PLOS Search API" do
      response = subject.get_data(from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the PLOS Search API" do
      response = subject.get_data
      expect(response["response"]["numFound"]).to eq(466)
      doc = response["response"]["docs"].first
      expect(doc["id"]).to eq("10.1371/journal.pone.0122673")
    end

    it "should catch errors with the PLOS Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.plos.org/search?fl=id%2Cpublication_date%2Ctitle_display%2Ccross_published_journal_name%2Cauthor_display%2Cvolume%2Cissue%2Celocation_id&fq=publication_date%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D%2Bdoc_type%3Afull&q=%2A%3A%2A&rows=0&start=0&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are works returned by the PLOS Search API" do
      body = File.read(fixture_path + 'plos_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(29)
      expect(response.first[:prefix]).to eq("10.1371")
      expect(response.first[:relation]).to eq("subj_id"=>"http://doi.org/10.1371/journal.pone.0075114",
                                              "source_id"=>"plos_import",
                                              "publisher_id"=>340)

      expect(response.first[:subj]).to eq("pid"=>"http://doi.org/10.1371/journal.pone.0075114",
                                          "author"=>[{"family"=>"Haga", "given"=>"Tomoaki"},
                                                     {"family"=>"Hirakawa", "given"=>"Hidehiko"},
                                                     {"family"=>"Nagamune", "given"=>"Teruyuki"}],
                                          "container-title"=>"PLOS ONE",
                                          "title"=>"Fine Tuning of Spatial Arrangement of Enzymes in a PCNA-Mediated Multienzyme Complex Using a Rigid Poly-L-Proline Linker",
                                          "issued"=>"2013-09-05T00:00:00Z",
                                          "DOI"=>"10.1371/journal.pone.0075114",
                                          "publisher_id"=>340,
                                          "volume"=>nil,
                                          "issue"=>nil,
                                          "page"=>nil,
                                          "tracked"=>true,
                                          "type"=>"article-journal")
    end
  end
end
