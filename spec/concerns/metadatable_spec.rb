require 'rails_helper'

describe Work, type: :model, vcr: true do
  context "metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: "17183658") }
    let!(:publisher) { "CDL.DRYAD" }

    it "get_metadata crossref" do
      response = subject.get_metadata(work.doi, "crossref")
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["container-title"]).to eq("PLoS ONE")
      expect(response["issued"]).to eq("2006-12-20")
      expect(response["published"]).to eq("2006-12-20")
      expect(response["deposited"]).to eq("2017-01-01T03:37:08Z")
      expect(response["updated"]).to eq("2017-01-01T04:40:02Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("340")
      expect(response["registration_agency_id"]).to eq("crossref")
    end

    it "get_metadata datacite" do
      work = FactoryGirl.create(:work, doi: "10.5438/4K3M-NYVG")
      response = subject.get_metadata(work.doi, "datacite")
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("Eating your own Dog Food")
      expect(response["container-title"]).to eq("DataCite")
      expect(response["author"]).to eq([{"family"=>"Fenner", "given"=>"Martin", "ORCID"=>"http://orcid.org/0000-0003-1419-2405"}])
      expect(response["issued"]).to eq("2016-12-20")
      expect(response["published"]).to eq("2016")
      expect(response["deposited"]).to eq("2016-12-19T20:49:21Z")
      expect(response["updated"]).to eq("2017-01-09T13:53:12Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("BlogPosting")
      expect(response["publisher_id"]).to eq("DATACITE.DATACITE")
      expect(response["registration_agency_id"]).to eq("datacite")
    end

    it "get_metadata pubmed" do
      response = subject.get_metadata(work.pmid, "pubmed")
      expect(response["pmid"]).to eq(work.pmid)
      expect(response["title"]).to eq("Triose phosphate isomerase deficiency is caused by altered dimerization--not catalytic inactivity--of the mutant enzymes")
      expect(response["container-title"]).to eq("PLoS One")
      expect(response["issued"]).to eq("2006")
      expect(response["type"]).to eq("article-journal")
      expect(response["publisher_id"]).to be_nil
    end

    it "get_metadata orcid" do
      orcid = "0000-0002-0159-2197"
      response = subject.get_metadata(orcid, "orcid")
      expect(response["title"]).to eq("ORCID record for Jonathan A. Eisen")
      expect(response["container-title"]).to eq("ORCID Registry")
      expect(response["issued"]).to eq("2015")
      expect(response["type"]).to eq("entry")
      expect(response["URL"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "get_metadata github" do
      url = "https://github.com/lagotto/lagotto"
      response = subject.get_metadata(url, "github")
      expect(response["title"]).to eq("Tracking events around scholarly content")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-02T22:07:40Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto")
    end

    it "get_metadata github_owner" do
      url = "https://github.com/lagotto"
      response = subject.get_metadata(url, "github_owner")
      expect(response["title"]).to eq("Github profile for Lagotto")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-01T19:38:33Z")
      expect(response["type"]).to eq("entry")
      expect(response["URL"]).to eq("https://github.com/lagotto")
    end

    it "get_metadata github_release" do
      url = "https://github.com/lagotto/lagotto/tree/v.4.3"
      response = subject.get_metadata(url, "github_release")
      expect(response["title"]).to eq("Lagotto 4.3")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2015-07-19T22:43:10Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto/tree/v.4.3")
    end

    it "get_metadata github_release missing title and date" do
      url = "https://github.com/brian-j-smith/Mamba.jl/tree/v0.4.8"
      response = subject.get_metadata(url, "github_release")
      expect(response["title"]).to eq("Mamba 0.4.8")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2015-05-21T01:52:37Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/brian-j-smith/Mamba.jl/tree/v0.4.8")
    end
  end

  context "crossref metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030") }

    it "get_crossref_metadata" do
      response = subject.get_crossref_metadata(work.doi)
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(response["container-title"]).to eq("PLoS ONE")
      expect(response["author"]).to eq([{"given"=>"Markus", "family"=>"Ralser"}, {"given"=>"Gino", "family"=>"Heeren"}, {"given"=>"Michael", "family"=>"Breitenbach"}, {"given"=>"Hans", "family"=>"Lehrach"}, {"given"=>"Sylvia", "family"=>"Krobitsch"}])
      expect(response["issued"]).to eq("2006-12-20")
      expect(response["published"]).to eq("2006-12-20")
      expect(response["deposited"]).to eq("2017-01-01T03:37:08Z")
      expect(response["updated"]).to eq("2017-01-01T04:40:02Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("340")
      expect(response["registration_agency_id"]).to eq("crossref")
    end

    it "get_crossref_metadata with old DOI" do
      work = FactoryGirl.create(:work, doi: "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2")
      response = subject.get_crossref_metadata(work.doi)
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
      expect(response["container-title"]).to eq("Ecology")
      expect(response["issued"]).to eq("2006-11")
      expect(response["published"]).to eq("2006-11")
      expect(response["deposited"]).to eq("2016-10-04T23:20:17Z")
      expect(response["updated"]).to eq("2016-11-28T12:49:49Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("311")
    end

    it "get_crossref_metadata with date in future" do
      work = FactoryGirl.create(:work, doi: "10.1016/j.ejphar.2015.03.018")
      response = subject.get_crossref_metadata(work.doi)
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
      expect(response["container-title"]).to eq("European Journal of Pharmacology")
      expect(response["issued"]).to eq("2016-11-02T20:32:47Z")
      expect(response["published"]).to eq("2015-07")
      expect(response["deposited"]).to eq("2016-08-20T08:19:38Z")
      expect(response["updated"]).to eq("2016-11-02T20:32:47Z")
      expect(response["resource_type_id"]).to eq("Text")
      expect(response["resource_type"]).to eq("journal-article")
      expect(response["publisher_id"]).to eq("78")
    end

    it "get_crossref_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_crossref_metadata("#{work.doi}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end

    it "generate datacite metadata" do
      metadata = subject.get_crossref_metadata(work.doi)
      datacite_metadata = subject.metadata_for_datacite(metadata)
      expect(datacite_metadata["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
      expect(datacite_metadata["publisher"]).to eq("PLoS ONE")
      expect(datacite_metadata["publication_year"]).to eq("2006")
    end
  end

  context "datacite metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:work) { FactoryGirl.create(:work, doi: "10.5061/DRYAD.8515") }

    it "get_datacite_metadata" do
      response = subject.get_datacite_metadata(work.doi)
      expect(response["DOI"]).to eq(work.doi)
      expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
      expect(response["container-title"]).to eq("Dryad Digital Repository")
      expect(response["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"}, {"family"=>"Durand", "given"=>"Patrick"}, {"family"=>"Prugnolle", "given"=>"Franck"}, {"family"=>"Douzery", "given"=>"Emmanuel J. P."}, {"family"=>"Arnathau", "given"=>"Céline"}, {"family"=>"Nkoghe", "given"=>"Dieudonné"}, {"family"=>"Leroy", "given"=>"Eric"}, {"family"=>"Renaud", "given"=>"François"}])
      expect(response["issued"]).to be_nil
      expect(response["published"]).to eq("2011")
      expect(response["deposited"]).to eq("2011-02-01T17:32:02Z")
      expect(response["updated"]).to eq("2017-02-04T17:54:39Z")
      expect(response["resource_type_id"]).to eq("Dataset")
      expect(response["resource_type"]).to eq("DataPackage")
      expect(response["publisher_id"]).to eq("CDL.DRYAD")
      expect(response["registration_agency_id"]).to eq("datacite")
    end

    it "get_datacite_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.5061/dryad.8515", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_datacite_metadata("#{work.doi}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end
  end

  context "pubmed metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: "17183658") }

    it "get_pubmed_metadata" do
      response = subject.get_pubmed_metadata(work.pmid)
      expect(response["pmid"]).to eq(work.pmid)
      expect(response["title"]).to eq("Triose phosphate isomerase deficiency is caused by altered dimerization--not catalytic inactivity--of the mutant enzymes")
      expect(response["container-title"]).to eq("PLoS One")
      expect(response["issued"]).to eq("2006")
      expect(response["type"]).to eq("article-journal")
      expect(response["publisher_id"]).to be_nil
    end

    it "get_pubmed_metadata with not found error" do
      ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
      response = subject.get_pubmed_metadata("#{work.pmid}x")
      expect(response).to eq(error: "Resource not found.", status: 404)
    end
  end

  context "orcid metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:orcid) { "0000-0002-0159-2197" }

    it "get_orcid_metadata" do
      response = subject.get_orcid_metadata(orcid)
      expect(response["title"]).to eq("ORCID record for Jonathan A. Eisen")
      expect(response["container-title"]).to eq("ORCID Registry")
      expect(response["issued"]).to eq("2015")
      expect(response["type"]).to eq("entry")
      expect(response["URL"]).to eq("http://orcid.org/0000-0002-0159-2197")
    end

    it "get_orcid_metadata with not found error" do
      response = subject.get_orcid_metadata("#{orcid}x")
      expect(response).to eq("errors"=>"Resource not found.")
    end
  end

  context "github metadata" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

    let(:url) { "https://github.com/lagotto/lagotto" }

    it "get_github_metadata" do
      response = subject.get_github_metadata(url)
      expect(response["title"]).to eq("Tracking events around scholarly content")
      expect(response["container-title"]).to eq("Github")
      expect(response["issued"]).to eq("2012-05-02T22:07:40Z")
      expect(response["type"]).to eq("computer_program")
      expect(response["URL"]).to eq("https://github.com/lagotto/lagotto")
    end

    it "get_github_metadata with not found error" do
      response = subject.get_github_metadata("#{url}x")
      expect(response).to eq(:error=>"Resource not found.", :status=>404)
    end
  end

  context "datacite_xml" do
    let(:doi) { "10.5072/0000-03VC" }
    let(:url) { "http://www.datacite.org" }
    let(:creators) { [{ given_name: "Elizabeth", family_name: "Miller", orcid: "0000-0001-5000-0007" }] }
    let(:title) { "Full DataCite XML Example" }
    let(:publisher) { "DataCite" }
    let(:publication_year) { 2014 }
    let(:resource_type) { { value: "XML", resource_type_general: "Software" } }
    let(:subjects) { ["000 computer science"] }
    let(:descriptions) { [{ value: "XML example of all DataCite Metadata Schema v4.0 properties.", description_type: "Abstract" }] }
    let(:rights_list) { [{ value: "CC0 1.0 Universal", rights_uri: "http://creativecommons.org/publicdomain/zero/1.0/" }] }
    let(:media) { [{ mime_type: "application/pdf", url:"http://www.datacite.org/cirneco-test.pdf" }]}
    let(:metadata) { { "doi" => doi,
                       "url" => url,
                       "creators" => creators,
                       "title" => title,
                       "publisher" => publisher,
                       "publication_year" => publication_year,
                       "resource_type" => resource_type,
                       "subjects" => subjects,
                       "descriptions" => descriptions,
                       "rights_list" => rights_list,
                       "media" => media } }

    it "generates valid xml" do
      datacite_work = subject.datacite_xml(metadata)
      expect(datacite_work.validation_errors.body["errors"]).to be_empty
    end

    it "includes creators" do
      xml =  Hash.from_xml(subject.datacite_xml(metadata).data).fetch("resource", {})
      authors = xml.fetch("creators", {}).fetch("creator", [])
      expect(authors).to eq("creatorName"=>"Miller, Elizabeth", "givenName"=>"Elizabeth", "familyName"=>"Miller", "nameIdentifier"=>"0000-0001-5000-0007")
    end
  end
end
