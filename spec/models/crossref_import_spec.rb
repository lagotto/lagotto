require 'rails_helper'

describe CrossrefImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:crossref_import) }

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
      subject = FactoryGirl.create(:crossref_import, ignore_members: true)
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
      expect(subject.get_total).to eq(430468)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2015-04-05", until_date: "2015-04-05")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.queue_jobs(from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.queue_jobs
      expect(response).to eq(430468)
    end

    it "should report if there are sample works returned by the Crossref REST API" do
      subject.sample = 20
      response = subject.queue_jobs
      expect(response).to eq(20)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      response = subject.get_data(nil, from_date: "2015-04-05", until_date: "2015-04-05")
      expect(response["message"]["total-results"]).to eq(0)
    end

    it "should report if there are works returned by the Crossref REST API" do
      response = subject.get_data(nil)
      expect(response["message"]["total-results"]).to eq(430468)
      item = response["message"]["items"].first
      expect(item["DOI"]).to eq("10.1016/0304-3975(85)90099-4")
    end

    it "should catch errors with the Crossref REST API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(nil, rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://api.crossref.org/works?filter=from-update-date%3A2015-04-07%2Cuntil-update-date%3A2015-04-08&offset=0&rows=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, nil)).to eq(works: [])
    end

    it "should report if there are works returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works].first
      expect(related_work['author']).to eq([{"family"=>"Batra", "given"=>"Geeta"}, {"family"=>"Stone", "given"=>"Andrew H. W."}])
      expect(related_work['title']).to eq("Investment climate, capabilities and firm performance")
      expect(related_work['container-title']).to eq("OECD Journal: General Papers")
      expect(related_work['issued']).to eq("date-parts"=>[[2008, 7, 26]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1787/gen_papers-v2008-art6-en")
      expect(related_work['publisher_id']).to eq(1963)
    end

    it "should report if there are works with incomplete date returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['author']).to eq([{"family"=>"Moore", "given"=>"J. W"}])
      expect(related_work['title']).to eq("Sanitary and meteorological notes")
      expect(related_work['container-title']).to eq("The Dublin Journal of Medical Science")
      expect(related_work['issued']).to eq("date-parts"=>[[1884, 8]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1007/bf02975686")
    end

    it "should report if there are works with date in the future returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import_future.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(1)
      related_work = response[:works].first
      expect(related_work['author']).to eq([{"affiliation"=>[], "family"=>"Beck", "given"=>"Sarah E."}, {"affiliation"=>[], "family"=>"Queen", "given"=>"Suzanne E."}, {"affiliation"=>[], "family"=>"Witwer", "given"=>"Kenneth W."}, {"affiliation"=>[], "family"=>"Metcalf Pate", "given"=>"Kelly A."}, {"affiliation"=>[], "family"=>"Mangus", "given"=>"Lisa M."}, {"affiliation"=>[], "family"=>"Gama", "given"=>"Lucio"}, {"affiliation"=>[], "family"=>"Adams", "given"=>"Robert J."}, {"affiliation"=>[], "family"=>"Clements", "given"=>"Janice E."}, {"affiliation"=>[], "family"=>"Christine Zink", "given"=>"M."}, {"affiliation"=>[], "family"=>"Mankowski", "given"=>"Joseph L."}])
      expect(related_work['title']).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(related_work['container-title']).to eq("European Journal of Pharmacology")
      expect(related_work['issued']).to eq("date-parts"=>[[2015, 5, 24]])
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1016/j.ejphar.2015.03.018")
    end

    it "should report if there are works with title as second item returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][2]
      expect(related_work['title']).to eq("Human capital formation and foreign direct")
      expect(related_work['container-title']).to eq("OECD Journal: General Papers")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1787/gen_papers-v2008-art4-en")
    end

    it "should report if there are works with missing title returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['title']).to be_nil
      expect(related_work['container-title']).to eq("The Dublin Journal of Medical Science")
      expect(related_work['type']).to eq("article-journal")
      expect(related_work['DOI']).to eq("10.1007/bf02975686")
    end

    it "should report if there are works with missing title journal-issue returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['title']).to eq("The Dublin Journal of Medical Science")
      expect(related_work['container-title']).to eq("The Dublin Journal of Medical Science")
      expect(related_work['type']).to be_nil
      expect(related_work['DOI']).to eq("10.1007/bf02975686")
    end

    it "should report if there are works with missing title missing container-title journal-issue returned by the Crossref REST API" do
      body = File.read(fixture_path + 'crossref_import.json')
      result = JSON.parse(body)
      result["message"]["items"][5]["title"] = []
      result["message"]["items"][5]["container-title"] = []
      result["message"]["items"][5]["type"] = "journal-issue"
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['title']).to eq("No title")
      expect(related_work['container-title']).to be_nil
      expect(related_work['type']).to be_nil
      expect(related_work['DOI']).to eq("10.1007/bf02975686")
    end
  end
end
