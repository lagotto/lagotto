require 'rails_helper'

describe LagottoRegistrationAgency, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2016, 4, 22)) }

  subject { FactoryGirl.create(:lagotto_registration_agency) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2016-04-21&until_date=2016-04-22&page=1&per_page=1000")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2016-04-21&until_date=2016-04-22&page=1&per_page=0")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2015-04-05&until_date=2015-04-05&page=1&per_page=1000")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 25)).to eq("http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2016-04-21&until_date=2016-04-22&page=25&per_page=1000")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2016-04-21&until_date=2016-04-22&page=1&per_page=250")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(95)
    end

    it "with no works" do
      expect(subject.get_total(from_date: "2009-04-07", until_date: "2009-04-08")).to eq(0)
    end
  end

  context "queue_jobs" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.queue_jobs
      expect(response).to eq(95)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["meta"]["total"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["meta"]["total"]).to eq(95)
      deposit = response["deposits"].first
      expect(deposit["subj_id"]).to eq("http://doi.org/10.5517/CCDC.CSD.CC1K1HY1")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://10.2.2.6/api/deposits?registration_agency_id=crossref&from_date=2016-04-21&until_date=2016-04-22&page=1&per_page=0", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'lagotto_registration_agency_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      FactoryGirl.create(:registration_agency)
      FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite")
      FactoryGirl.create(:relation_type, :is_part_of)
      body = File.read(fixture_path + 'lagotto_registration_agency.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(95)
      expect(response[1]["subj_id"]).to eq("http://doi.org/10.5517/CCDC.CSD.CC1JW79Y")
      expect(response[1]["obj_id"]).to eq("http://doi.org/10.1016/J.ICA.2016.04.009")
      expect(response[1]["relation_type_id"]).to eq("is_supplement_to")
      expect(response[1]["source_id"]).to eq("datacite_crossref")
      expect(response[1]["subj"]).to eq("pid"=>"http://doi.org/10.5517/CCDC.CSD.CC1JW79Y",
                                        "DOI"=>"10.5517/CCDC.CSD.CC1JW79Y",
                                        "author"=>[{"family"=>"Okayama", "given"=>"Tetsuya"}, {"family"=>"Watanabe", "given"=>"Takashi"}, {"family"=>"Hatayama", "given"=>"Yuki"}, {"family"=>"Ishihara", "given"=>"Shinji"}, {"family"=>"Yamaguchi", "given"=>"Yoshitaka"}],
                                        "title"=>"CCDC 1426350: Experimental Crystal Structure Determination",
                                        "container-title"=>"Cambridge Crystallographic Data Centre",
                                        "issued"=>"2016",
                                        "publisher_id"=>"BL.CCDC",
                                        "registration_agency"=>"datacite",
                                        "tracked"=>true,
                                        "type"=>"dataset")
    end

    it "should catch timeout errors with the Datacite Metadata Search API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end
end
