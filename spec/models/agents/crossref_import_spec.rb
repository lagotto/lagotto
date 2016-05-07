require 'rails_helper'

describe CrossrefImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:crossref_import) }

  context "config_fields" do
    it "url_fields" do
      expect(subject.url_fields).to eq([:url])
    end

    it "publisher_fields" do
      expect(subject.publisher_fields).to eq([:sample, :only_publishers])
    end

    it "other_fields" do
      expect(subject.other_fields).to be_empty
    end
  end

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=1000")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-05%2Cuntil-update-date%3A2015-04-05&offset=0&rows=1000")
    end

    it "with member_id" do
      FactoryGirl.create(:publisher)
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08%2Cmember%3A340&offset=0&rows=1000")
    end

    it "ignoring member_id" do
      FactoryGirl.create(:publisher)
      subject = FactoryGirl.create(:crossref_import, only_publishers: false)
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=1000")
    end

    it "with sample" do
      subject = FactoryGirl.create(:crossref_import, sample: 100)
      expect(subject.get_query_url).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&sample=100")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=250&rows=1000")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=250")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(142138)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "1915-04-05", until_date: "1915-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.queue_jobs(from_date: "1915-04-05", until_date: "1915-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.queue_jobs
      expect(response).to eq(142138)
    end

    it "should report if there are sample works returned by the Crossref REST API" do
      subject.sample = 20
      response = subject.queue_jobs
      expect(response).to eq(20)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.get_data(from_date: "1915-04-05", until_date: "1915-04-05")
      expect(response["message"]["total-results"]).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.get_data
      expect(response["message"]["total-results"]).to eq(142138)
      item = response["message"]["items"].first
      expect(item["DOI"]).to eq("10.15857/ksep.2008.17.4.483")
    end

    it "should catch errors with the Crossref REST API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[0][:prefix]).to eq("10.1787")
      expect(response[0][:relation]).to eq("subj_id"=>"http://doi.org/10.1787/gen_papers-v2008-art6-en",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"1963")

      expect(response[0][:subj]).to eq("pid"=>"http://doi.org/10.1787/gen_papers-v2008-art6-en",
                                       "author"=>[{"family"=>"Batra", "given"=>"Geeta"},
                                                  {"family"=>"Stone", "given"=>"Andrew H. W."}],
                                       "container-title"=>"OECD Journal: General Papers",
                                       "title"=>"Investment climate, capabilities and firm performance",
                                       "published" => nil,
                                       "issued"=>"2008-07-26",
                                       "DOI"=>"10.1787/gen_papers-v2008-art6-en",
                                       "publisher_id"=>"1963",
                                       "volume"=>"2008",
                                       "issue"=>"1",
                                       "page"=>"1-37",
                                       "type"=>"article-journal",
                                       "registration_agency_id" => "crossref",
                                       "tracked"=>true)
    end

    it "should report if there are works with incomplete date returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[5][:prefix]).to eq("10.1007")
      expect(response[5][:relation]).to eq("subj_id"=>"http://doi.org/10.1007/bf02975686",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"297")

      expect(response[5][:subj]).to eq("pid"=>"http://doi.org/10.1007/bf02975686",
                                       "author"=>[{"family"=>"Moore", "given"=>"J. W"}],
                                       "container-title"=>"The Dublin Journal of Medical Science",
                                       "title"=>"Sanitary and meteorological notes",
                                       "published" => nil,
                                       "issued"=>"1884-08",
                                       "DOI"=>"10.1007/bf02975686",
                                       "publisher_id"=>"297",
                                       "volume"=>"78",
                                       "issue"=>"2",
                                       "page"=>"185-189",
                                       "type"=>"article-journal",
                                       "registration_agency_id" => "crossref",
                                       "tracked"=>true)
    end

    it "should report if there are works with date in the future returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import_future.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(1)
      expect(response[0][:prefix]).to eq("10.1016")
      expect(response[0][:relation]).to eq("subj_id"=>"http://doi.org/10.1016/j.ejphar.2015.03.018",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"78")

      expect(response[0][:subj]).to eq("pid"=>"http://doi.org/10.1016/j.ejphar.2015.03.018",
                                       "author"=>[{"family"=>"Beck", "given"=>"Sarah E."},
                                                  {"family"=>"Queen", "given"=>"Suzanne E."},
                                                  {"family"=>"Witwer", "given"=>"Kenneth W."},
                                                  {"family"=>"Metcalf Pate", "given"=>"Kelly A."},
                                                  {"family"=>"Mangus", "given"=>"Lisa M."},
                                                  {"family"=>"Gama", "given"=>"Lucio"},
                                                  {"family"=>"Adams", "given"=>"Robert J."},
                                                  {"family"=>"Clements", "given"=>"Janice E."},
                                                  {"family"=>"Christine Zink", "given"=>"M."},
                                                  {"family"=>"Mankowski", "given"=>"Joseph L."}],
                                       "container-title"=>"European Journal of Pharmacology",
                                       "title"=>"Paving the path to HIV neurotherapy: Predicting SIV CNS disease",
                                       "published" => "2015-07",
                                       "issued"=>"2015-05-24",
                                       "DOI"=>"10.1016/j.ejphar.2015.03.018",
                                       "publisher_id"=>"78", "volume"=>"759",
                                       "issue"=>nil,
                                       "page"=>"303-312",
                                       "type"=>"article-journal",
                                       "registration_agency_id" => "crossref",
                                       "tracked"=>true)
    end

    it "should report if there are works with title as second item returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[2][:prefix]).to eq("10.1787")
      expect(response[2][:relation]).to eq("subj_id"=>"http://doi.org/10.1787/gen_papers-v2008-art4-en",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"1963")

      expect(response[2][:subj]).to eq("pid"=>"http://doi.org/10.1787/gen_papers-v2008-art4-en",
                                       "author"=>[{"family"=>"Miyamoto", "given"=>"Koji"}],
                                       "container-title"=>"OECD Journal: General Papers",
                                       "title"=>"Human capital formation and foreign direct",
                                       "published" => nil,
                                       "issued"=>"2008-07-26",
                                       "DOI"=>"10.1787/gen_papers-v2008-art4-en",
                                       "publisher_id"=>"1963",
                                       "volume"=>"2008",
                                       "issue"=>"1",
                                       "page"=>"1-40",
                                       "type"=>"article-journal",
                                       "registration_agency_id" => "crossref",
                                       "tracked"=>true)
    end

    it "should report if there are works with missing title returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[5][:prefix]).to eq("10.1007")
      expect(response[5][:relation]).to eq("subj_id"=>"http://doi.org/10.1007/bf02975686",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"297")

      expect(response[5][:subj]).to eq("pid"=>"http://doi.org/10.1007/bf02975686",
                                       "author"=>[{"family"=>"Moore", "given"=>"J. W"}],
                                       "container-title"=>"The Dublin Journal of Medical Science",
                                       "title"=>nil,
                                       "published" => nil,
                                       "issued"=>"1884-08",
                                       "DOI"=>"10.1007/bf02975686",
                                       "publisher_id"=>"297",
                                       "volume"=>"78",
                                       "issue"=>"2",
                                       "page"=>"185-189",
                                       "type"=>"article-journal",
                                       "tracked"=>true,
                                       "registration_agency_id" => "crossref")
    end

    it "should report if there are works with missing title journal-issue returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[5][:prefix]).to eq("10.1007")
      expect(response[5][:relation]).to eq("subj_id"=>"http://doi.org/10.1007/bf02975686",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"297")

      expect(response[5][:subj]).to eq("pid"=>"http://doi.org/10.1007/bf02975686",
                                       "author"=>[{"family"=>"Moore", "given"=>"J. W"}],
                                       "container-title"=>"The Dublin Journal of Medical Science",
                                       "title"=>"The Dublin Journal of Medical Science",
                                       "published" => nil,
                                       "issued"=>"1884-08",
                                       "DOI"=>"10.1007/bf02975686",
                                       "publisher_id"=>"297",
                                       "volume"=>"78",
                                       "issue"=>"2",
                                       "page"=>"185-189",
                                       "type"=>nil,
                                       "tracked"=>true,
                                       "registration_agency_id" => "crossref")
    end

    it "should report if there are works with missing title missing container-title journal-issue returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["container-title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"
      response = subject.parse_data(result)

      expect(response.length).to eq(10)
      expect(response[5][:prefix]).to eq("10.1007")
      expect(response[5][:relation]).to eq("subj_id"=>"http://doi.org/10.1007/bf02975686",
                                           "source_id"=>"crossref_import",
                                           "publisher_id"=>"297")

      expect(response[5][:subj]).to eq("pid"=>"http://doi.org/10.1007/bf02975686",
                                       "author"=>[{"family"=>"Moore", "given"=>"J. W"}],
                                       "container-title"=>nil,
                                       "title"=>"No title",
                                       "published" => nil,
                                       "issued"=>"1884-08",
                                       "DOI"=>"10.1007/bf02975686",
                                       "publisher_id"=>"297",
                                       "volume"=>"78",
                                       "issue"=>"2",
                                       "page"=>"185-189",
                                       "type"=>nil,
                                       "tracked"=>true,
                                       "registration_agency_id" => "crossref")
    end

    it "should catch timeout errors with the Crossref Metadata Search API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end
end
