require 'rails_helper'

describe DataciteGithub, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:datacite_github) }

  context "get_query_url" do
    it "default" do
      expect(subject.get_query_url).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with zero rows" do
      expect(subject.get_query_url(rows: 0)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with different from_date and until_date" do
      expect(subject.get_query_url(from_date: "2015-04-05", until_date: "2015-04-05")).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-05T00%3A00%3A00Z+TO+2015-04-05T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with offset" do
      expect(subject.get_query_url(offset: 10)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=10&rows=1000&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end

    it "with rows" do
      expect(subject.get_query_url(rows: 250)).to eq("http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=250&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json")
    end
  end

  context "get_total" do
    it "with works" do
      expect(subject.get_total).to eq(19)
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
      expect(response).to eq(19)
    end
  end

  context "get_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      response = subject.get_data(from_date: "2009-04-07", until_date: "2009-04-08")
      expect(response["response"]["numFound"]).to eq(0)
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      response = subject.get_data
      expect(response["response"]["numFound"]).to eq(19)
      doc = response["response"]["docs"].first
      expect(doc["doi"]).to eq("10.5281/ZENODO.16396")
    end

    it "should catch errors with the Datacite Metadata Search API" do
      stub = stub_request(:get, subject.get_query_url(rows: 0, source_id: subject.source_id)).to_return(:status => [408])
      response = subject.get_data(rows: 0, source_id: subject.source_id)
      expect(response).to eq(error: "the server responded with status 408 for http://search.datacite.org/api?q=relatedIdentifier%3AURL%5C%3Ahttps%5C%3A%5C%2F%5C%2Fgithub.com*&start=0&rows=0&fl=doi%2Ccreator%2Ctitle%2Cpublisher%2CpublicationYear%2CresourceTypeGeneral%2Cdatacentre_symbol%2CrelatedIdentifier%2CnameIdentifier%2Cxml%2Cminted%2Cupdated&fq=updated%3A%5B2015-04-07T00%3A00%3A00Z+TO+2015-04-08T23%3A59%3A59Z%5D+AND+has_metadata%3Atrue+AND+is_active%3Atrue&wt=json", :status=>408)
      expect(stub).to have_been_requested
      expect(Notification.count).to eq(1)
      notification = Notification.first
      expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
      expect(notification.status).to eq(408)
    end
  end

  context "parse_data" do
    it "should report if there are no works returned by the Datacite Metadata Search API" do
      body = File.read(fixture_path + 'datacite_github_nil.json')
      result = JSON.parse(body)
      expect(subject.parse_data(result)).to eq([])
    end

    it "should report if there are works returned by the Datacite Metadata Search API" do
      FactoryGirl.create(:relation_type, :is_supplement_to)
      body = File.read(fixture_path + 'datacite_github.json')
      result = JSON.parse(body)
      response = subject.parse_data(result)

      expect(response.length).to eq(60)
      expect(response[2][:prefix]).to eq("10.5281")
      expect(response[2][:relation]).to eq("subj_id"=>"http://doi.org/10.5281/ZENODO.16396",
                                           "obj_id"=>"https://github.com/SlicerProstate/SlicerProstate",
                                           "relation_type_id"=>"is_supplement_to",
                                           "source_id"=>"datacite_github",
                                           "publisher_id"=>"CERN.ZENODO",
                                           "registration_agency_id" => "github",
                                           "occurred_at"=>"2015-03-26T20:45:10Z")

      expect(response[2][:subj]).to eq("pid"=>"http://doi.org/10.5281/ZENODO.16396",
                                       "DOI"=>"10.5281/ZENODO.16396",
                                       "author"=>[{"family"=>"Fedorov", "given"=>"Andrey"}, {"family"=>"Nguyen", "given"=>"Paul L"}, {"family"=>"Tuncali", "given"=>"Kemal"}, {"family"=>"Tempany", "given"=>"Clare"}],
                                       "title"=>"Annotated MRI and ultrasound volume images of the prostate",
                                       "container-title"=>"Zenodo",
                                       "published"=>"2015",
                                       "issued"=>"2015-03-26T20:45:10Z",
                                       "publisher_id"=>"CERN.ZENODO",
                                       "registration_agency_id"=>"datacite",
                                       "tracked"=>true,
                                       "type"=>"dataset")

      expect(response[3][:message_type]).to eq("contribution")
      expect(response[3][:relation]).to eq("subj_id"=>"https://github.com/SlicerProstate",
                                           "obj_id"=>"https://github.com/SlicerProstate/SlicerProstate",
                                           "source_id"=>"github_contributor",
                                           "registration_agency_id" => "github")
    end

    it "should catch timeout errors with the Datacite Metadata Search API" do
      result = { error: "the server responded with status 408 for http://www.citeulike.org/api/posts/for/doi/", status: 408 }
      response = subject.parse_data(result)
      expect(response).to eq([result])
    end
  end
end
