require 'rails_helper'

describe DataciteImport, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:datacite_import) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with name" do
      FactoryGirl.create(:publisher, name: "CDL.DRYAD", registration_agency: "datacite")
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue+AND+datacentre_symbol%3ACDL.DRYAD&wt=json")
    end

    it "ignoring name" do
      FactoryGirl.create(:publisher, name: "CDL.DRYAD", registration_agency: "datacite")
      subject = FactoryGirl.create(:datacite_import, only_publishers: false)
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 250)).to eq("http://search.datacite.org/api?q=*%3A*&start=250&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=*%3A*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(4109)
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
      expect(response).to eq(4109)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["response"]["numFound"]).to eq(4109)
      doc = response["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5517/CC13D9MF")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, agent_id: subject.id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, agent_id: subject.id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=*%3A*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
      expect(notification.agent_id).to eq(subject.id)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_import_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result, nil)).to eq(:works=>[], :events=>[])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works].last
      expect(related_work['author']).to eq([{"family"=>"Eggers", "given"=>"Florian"}, {"family"=>"Slotte", "given"=>"Aril"}, {"family"=>"Libungan", "given"=>"Lisa Anne"}, {"family"=>"Johannessen", "given"=>"Arne"}, {"family"=>"Kvamme", "given"=>"Cecilie"}, {"family"=>"Moland", "given"=>"Even"}, {"family"=>"Olsen", "given"=>"Esben Moland"}, {"family"=>"Nash", "given"=>"Richard D. M."}])
      expect(related_work['title']).to eq("Data 2012 Landvik")
      expect(related_work['container-title']).to be_nil
      expect(related_work['issued']).to eq("date-parts"=>[[2013]])
      expect(related_work['type']).to eq("dataset")
      expect(related_work['DOI']).to eq("10.5061/DRYAD.QT984/1")
    end

    it "should report if there are works with incomplete date returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_import.json')
      result = JSON.parse(body)
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['author']).to eq([{"family"=>"Pellino", "given"=>"Marco"}, {"family"=>"Hojsgaard", "given"=>"Diego"}, {"family"=>"Schmutzer", "given"=>"Thomas"}, {"family"=>"Scholz", "given"=>"Uwe"}, {"family"=>"Vogel", "given"=>"Heiko"}, {"family"=>"Hörandl", "given"=>"Elvira"}, {"family"=>"Sharbel", "given"=>"Tim"}])
      expect(related_work['title']).to eq("Presence/absence SNPs matrix")
      expect(related_work['container-title']).to be_nil
      expect(related_work['issued']).to eq("date-parts"=>[[2013]])
      expect(related_work['type']).to eq("dataset")
      expect(related_work['DOI']).to eq("10.5061/DRYAD.NK151/2")
    end

    it "should report if there are works with missing title returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_import.json')
      result = JSON.parse(body)
      result["response"]["docs"][5]["title"] = []
      response = subject.parse_data(result, nil)

      expect(response[:works].length).to eq(10)
      related_work = response[:works][5]
      expect(related_work['title']).to be_nil
      expect(related_work['container-title']).to be_nil
      expect(related_work['type']).to eq("dataset")
      expect(related_work['DOI']).to eq("10.5061/DRYAD.NK151/2")
    end
  end
end
