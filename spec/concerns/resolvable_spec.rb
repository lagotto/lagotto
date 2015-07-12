require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "HTTP" do
    let(:work) { FactoryGirl.create(:work_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/works/info:doi/#{work.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "get_doi_ra" do
      it "doi crossref" do
        doi = "10.1371/journal.pone.0000030"
        expect(subject.get_doi_ra(doi)).to eq("crossref")
      end

      it "doi datacite" do
        doi = "10.5061/dryad.8515"
        expect(subject.get_doi_ra(doi)).to eq("datacite")
      end

      it "not found" do
        doi = "10.1371/xxx"
        expect(subject.get_doi_ra(doi)).to eq(error: "Resource not found.", status: 404)
      end
    end

    context "get_id_hash" do
      it "doi" do
        id = "doi:10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "pmid" do
        id = "pmid:17183658"
        expect(subject.get_id_hash(id)).to eq(pmid: "17183658")
      end

      it "http" do
        id = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(canonical_url: id)
      end

      it "http with one /" do
        id = "http:/journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(canonical_url: "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030")
      end

      it "https" do
        id = "https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(canonical_url: id)
      end

      it "https with one /" do
        id = "https:/journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(canonical_url: "https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030")
      end

      it "pmcid with PMC" do
        id = "pmcid:PMC1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "pmcid" do
        id = "pmcid:1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "arxiv" do
        id = "arxiv:1503.04201"
        expect(subject.get_id_hash(id)).to eq(arxiv: "1503.04201")
      end

      it "wos" do
        id = "wos:000237966900001"
        expect(subject.get_id_hash(id)).to eq(wos: "000237966900001")
      end

      it "scp" do
        id = "scp:33845338721"
        expect(subject.get_id_hash(id)).to eq(scp: "33845338721")
      end

      it "ark" do
        id = "ark:/13030/m5br8st1"
        expect(subject.get_id_hash(id)).to eq(ark: id)
      end

      it "http://doi.org" do
        id = "http://doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "http://dx.doi.org" do
        id = "http://dx.doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "http://www.ncbi.nlm.nih.gov/pubmed/" do
        id = "http://www.ncbi.nlm.nih.gov/pubmed/17183658"
        expect(subject.get_id_hash(id)).to eq(pmid: "17183658")
      end

      it "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC" do
        id = "http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "http://arxiv.org/abs/" do
        id = "http://arxiv.org/abs/1503.04201"
        expect(subject.get_id_hash(id)).to eq(arxiv: "1503.04201")
      end

      it "http://n2t.net/ark:" do
        id = "http://n2t.net/ark:/13030/m5br8st1"
        expect(subject.get_id_hash(id)).to eq(ark: "ark:/13030/m5br8st1")
      end

      it "doi/" do
        id = "doi/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "info:doi/" do
        id = "info:doi/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "10." do
        id = "10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end

      it "pmid/" do
        id = "pmid/17183658"
        expect(subject.get_id_hash(id)).to eq(pmid: "17183658")
      end

      it "pmcid/PMC/" do
        id = "pmcid/PMC1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "pmcid/" do
        id = "pmcid/1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "PMC" do
        id = "PMC1762313"
        expect(subject.get_id_hash(id)).to eq(pmcid: "1762313")
      end

      it "id" do
        id = "10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/journal.pone.0000030")
      end
    end

    context "canonical URL" do
      it "get_canonical_url" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=#{work.doi_escaped}"
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
      end

      # it "get_canonical_url with redirects" do
      #   stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
      #   stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url + "/x" })
      #   stub_request(:get, redirect_url+ "/x").to_return(status: 301, headers: { location: redirect_url + "/y" })
      #   stub_request(:get, redirect_url+ "/y").to_return(status: 301, headers: { location: redirect_url + "/z" })
      #   stub_request(:get, redirect_url + "/z").to_return(status: 200, body: "Test")
      #   response = subject.get_result(url)
      #   expect(response).to eq("Test")
      #   expect(Alert.count).to eq(0)
      # end

      it "get_canonical_url with trailing slash" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1080/10629360600569196")
        clean_url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        url = "#{clean_url}/"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with jsessionid" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0000030;jsessionid=5362E4D61F1953ADA2CB3F746E58AAC2.f01t03"
        clean_url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with cookies" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/>" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_canonical.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <meta property='og:url'/>" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_opengraph.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/> mismatch" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for http://journals.plos.org/plosone/article?id=#{work.doi_escaped}", status: 404)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPNotFound")
        expect(alert.status).to eq(404)
        expect(alert.message).to eq("Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for #{url}")
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with landing page" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.3109/09286586.2014.926940")
        url = "http://informahealthcare.com/action/cookieabsent"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "DOI #{work.doi} could not be resolved", status: 404)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPNotFound")
        expect(alert.status).to eq(404)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with not found error" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 404, :body => File.read(fixture_path + 'doi_not_found.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "DOI #{work.doi} could not be resolved", status: 404)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPNotFound")
        expect(alert.status).to eq(404)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url unauthorized error" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 401)
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 401 for http://doi.org/#{work.doi}", status: 401)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPUnauthorized")
        expect(alert.status).to eq(401)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with timeout error" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => [408])
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 408 for http://doi.org/#{work.doi}", status: 408)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(alert.status).to eq(408)
        expect(stub).to have_been_requested
      end
    end

    context "persistent identifiers" do
      let(:work) { FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030") }

      it "get_persistent_identifiers" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_persistent_identifiers(work.doi, "doi")
        expect(response).to include(ids)
        expect(response).not_to include("errmsg")
      end

      it "get_persistent_identifiers with not found error" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_persistent_identifiers("#{work.doi}x", "doi")
        expect(response).not_to include(ids)
        expect(response).to include("errmsg")
      end
    end

    context "metadata" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

      let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: "17183658") }

      it "get_metadata crossref" do
        response = subject.get_metadata(work.doi, "crossref")
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
        expect(response["container-title"]).to eq("PLoS ONE")
        expect(response["issued"]).to eq("date-parts"=>[[2006, 12, 20]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq(340)
      end

      it "get_metadata datacite" do
        work = FactoryGirl.create(:work, doi: "10.5061/dryad.8515")
        response = subject.get_metadata(work.doi, "datacite")
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
        expect(response["container-title"]).to be_nil
        expect(response["issued"]).to eq("date-parts"=>[[2011]])
        expect(response["type"]).to eq("dataset")
        expect(response["publisher_id"]).to be_nil
      end

      it "get_metadata pubmed" do
        response = subject.get_pubmed_metadata(work.pmid)
        expect(response["pmid"]).to eq(work.pmid)
        expect(response["title"]).to eq("Triose phosphate isomerase deficiency is caused by altered dimerization--not catalytic inactivity--of the mutant enzymes")
        expect(response["container-title"]).to eq("PLoS One")
        expect(response["issued"]).to eq("date-parts"=>[[2006]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to be_nil
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
        expect(response["issued"]).to eq("date-parts"=>[[2006, 12, 20]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq(340)
      end

      it "get_crossref_metadata with old DOI" do
        work = FactoryGirl.create(:work, doi: "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2")
        response = subject.get_crossref_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
        expect(response["container-title"]).to eq("Ecology")
        expect(response["issued"]).to eq("date-parts"=>[[2006, 11]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq(792)
      end

      it "get_crossref_metadata with date in future" do
        work = FactoryGirl.create(:work, doi: "10.1016/j.ejphar.2015.03.018")
        response = subject.get_crossref_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
        expect(response["container-title"]).to eq("European Journal of Pharmacology")
        expect(response["issued"]).to eq("date-parts"=>[[2015, 6, 10]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq(78)
      end

      it "get_crossref_metadata with not found error" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_crossref_metadata("#{work.doi}x")
        expect(response).to eq(error: "Resource not found.", status: 404)
      end
    end

    context "datacite metadata" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

      let(:work) { FactoryGirl.create(:work, doi: "10.5061/dryad.8515") }

      it "get_datacite_metadata" do
        response = subject.get_datacite_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
        expect(response["container-title"]).to be_nil
        expect(response["issued"]).to eq("date-parts"=>[[2011]])
        expect(response["type"]).to eq("dataset")
        expect(response["publisher_id"]).to be_nil
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
        expect(response["issued"]).to eq("date-parts"=>[[2006]])
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to be_nil
      end

      it "get_pubmed_metadata with not found error" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_pubmed_metadata("#{work.pmid}x")
        expect(response).to eq(error: "Resource not found.", status: 404)
      end
    end
  end
end
