require 'rails_helper'

describe CrossrefOrcid, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:crossref_orcid) }

  context "config_fields" do
    it "url_fields" do
      expect(subject.url_fields).to eq([:url])
    end

    it "other_fields" do
      expect(subject.other_fields).to be_empty
    end
  end

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=1000")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-05%2Cuntil-update-date%3A2015-04-05&offset=0&rows=1000")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=250&rows=1000")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=250")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(795)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "1999-04-05", until_date: "1999-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.queue_jobs(from_date: "1999-04-05", until_date: "1999-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.queue_jobs
      expect(response).to eq(795)
    end

    it "should report if there are sample works returned by the Crossref REST API" do
      subject.sample = 20
      response = subject.queue_jobs
      expect(response).to eq(20)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.get_data(from_date: "1999-04-05", until_date: "1999-04-05")
      expect(response["message"]["total-results"]).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.get_data
      expect(response["message"]["total-results"]).to eq(795)
      item = response["message"]["items"].first
      expect(item["DOI"]).to eq("10.1063/1.4916805")
    end

    it "should catch errors with the Crossref REST API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=has-orcid%3Atrue%2Cfrom-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_orcid_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_orcid.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response.first[:prefix]).to eq("10.1016")
      expect(response.first[:message_type]).to eq("contribution")
      expect(response.first[:relation]).to eq("subj_id"=>"http://orcid.org/0000-0001-9344-779X",
                                              "obj_id"=>"http://doi.org/10.1016/j.mmcr.2014.03.001",
                                              "source_id"=>"crossref_orcid",
                                              "publisher_id"=>"78")

      expect(response.first[:obj]).to eq("pid"=>"http://doi.org/10.1016/j.mmcr.2014.03.001",
                                          "author"=>[{"family"=>"Brown", "given"=>"Jeremy D."}, {"family"=>"Lim", "given"=>"Lyn-li"}, {"family"=>"Koning", "given"=>"Sonia", "ORCID"=>"http://orcid.org/0000-0001-9344-779X"}],
                                          "title"=>"Voriconazole associated torsades de pointes in two adult patients with haematological malignancies",
                                          "container-title"=>"Medical Mycology Case Reports",
                                          "published" => nil,
                                          "issued"=>"2014-04",
                                          "DOI"=>"10.1016/j.mmcr.2014.03.001",
                                          "publisher_id"=>"78",
                                          "volume"=>"4",
                                          "issue"=>nil,
                                          "page"=>"23-25",
                                          "type"=>"article-journal",
                                          "tracked"=>true,
                                          "registration_agency_id" => "crossref")
    end

    it "should catch timeout errors with the Crossref API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end
end
