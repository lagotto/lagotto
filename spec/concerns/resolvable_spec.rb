require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "HTTP" do
    let(:work) { FactoryGirl.create(:work, :with_events) }
    let(:url) { "http://127.0.0.1/api/v3/works/info:doi/#{work.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "get_doi_ra" do
      let!(:registration_agency) { FactoryGirl.create(:registration_agency) }

      it "doi crossref" do
        doi = "10.1371/journal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:name]).to eq("crossref")
        prefix = Prefix.first
        expect(prefix.registration_agency.name).to eq("crossref")
      end

      it "doi crossref escaped" do
        doi = "10.1371%2Fjournal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:name]).to eq("crossref")
        prefix = Prefix.first
        expect(prefix.registration_agency.name).to eq("crossref")
      end

      it "doi datacite" do
        FactoryGirl.create(:registration_agency, name: "datacite", title: "DataCite")
        doi = "10.5061/dryad.8515"
        ra = subject.get_doi_ra(doi)
        expect(ra[:name]).to eq("datacite")
        prefix = Prefix.first
        expect(prefix.registration_agency.name).to eq("datacite")
      end

      it "invalid DOI" do
        doi = "10.1371/xxx"
        expect(subject.get_doi_ra(doi)).to eq(error: "Invalid DOI", status: 400)
      end

      it "doi crossref cached prefix" do
        doi = "10.1371/journal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:name]).to eq("crossref")
      end
    end

    context "get_id_hash" do
      it "doi" do
        id = "doi:10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: '10.1371/JOURNAL.PONE.0000030')
      end

      it " downcase" do
        id = "doi:10.5063/F1PC3085"
        expect(subject.get_id_hash(id)).to eq(doi: "10.5063/F1PC3085")
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

      it "github" do
        id = "https://github.com/electronicvisions/ppu-software"
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
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      it "http://dx.doi.org" do
        id = "http://dx.doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
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

      it "n2t.net/ark:/90135/q1vm497c" do
        id = "n2t.net/ark:/90135/q1vm497c"
        expect(subject.get_id_hash(id)).to eq(ark: "ark:/90135/q1vm497c")
      end

      it "doi/" do
        id = "doi/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      it "info:doi/" do
        id = "info:doi/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      it "10." do
        id = "10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
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

      it "doi_" do
        id = "doi_10.5066_F7DZ067M"
        expect(subject.get_id_hash(id)).to eq(doi: "10.5066/F7DZ067M")
      end

      it "id" do
        id = "10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end
    end

    context "canonical URL" do
      it "get_canonical_url" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=#{work.doi_escaped}"
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url)
        expect(Notification.count).to eq(0)
      end

      # it "get_canonical_url with redirects" do
      #   stub_request(:get, url).to_return(status: 301, headers: { location: redirect_url })
      #   stub_request(:get, redirect_url).to_return(status: 301, headers: { location: redirect_url + "/x" })
      #   stub_request(:get, redirect_url+ "/x").to_return(status: 301, headers: { location: redirect_url + "/y" })
      #   stub_request(:get, redirect_url+ "/y").to_return(status: 301, headers: { location: redirect_url + "/z" })
      #   stub_request(:get, redirect_url + "/z").to_return(status: 200, body: "Test")
      #   response = subject.get_result(url)
      #   expect(response).to eq("Test")
      #   expect(Notification.count).to eq(0)
      # end

      it "get_canonical_url with trailing slash" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1080/10629360600569196", doi: "10.1080/10629360600569196")
        clean_url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        url = "#{clean_url}/"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Notification.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with jsessionid" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0000030;jsessionid=5362E4D61F1953ADA2CB3F746E58AAC2.f01t03"
        clean_url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Notification.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with cookies" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1080/10629360600569196", :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url)
        expect(Notification.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/>" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_canonical.html'))
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url)
        expect(Notification.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <meta property='og:url'/>" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_opengraph.html'))
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url)
        expect(Notification.count).to eq(0)
        expect(stub).to have_been_requested
      end

      # it "get_canonical_url with <link rel='canonical'/> mismatch" do
      #   work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
      #   url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
      #   stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
      #   stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work.html'))
      #   response = subject.get_canonical_url(work.pid, work_id: work.id)
      #   expect(response).to eq(error: "Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for http://journals.plos.org/plosone/article?id=#{work.doi_escaped}", status: 404)
      #   expect(Notification.count).to eq(1)
      #   notification = Notification.first
      #   expect(notification.class_name).to eq("Net::HTTPNotFound")
      #   expect(notification.status).to eq(404)
      #   expect(notification.message).to eq("Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for #{url}")
      #   expect(stub).to have_been_requested
      # end

      # it "get_canonical_url with landing page" do
      #   work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.3109/09286586.2014.926940", doi: "10.3109/09286586.2014.926940")
      #   url = "http://informahealthcare.com/action/cookieabsent"
      #   stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
      #   stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
      #   response = subject.get_canonical_url(work.pid, work_id: work.id)
      #   expect(response).to eq(error: "DOI #{work.doi} could not be resolved", status: 404)
      #   expect(Notification.count).to eq(1)
      #   notification = Notification.first
      #   expect(notification.class_name).to eq("Net::HTTPNotFound")
      #   expect(notification.status).to eq(404)
      #   expect(stub).to have_been_requested
      # end

      it "get_canonical_url with not found error" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)
        stub = stub_request(:get, work.pid).to_return(:status => 404, :body => File.read(fixture_path + 'doi_not_found.html'))
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(error: "DOI #{work.doi} could not be resolved", status: 404)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPNotFound")
        expect(notification.status).to eq(404)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url unauthorized error" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030")
        stub = stub_request(:get, work.pid).to_return(:status => 401)
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 401 for #{work.pid}", status: 401)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPUnauthorized")
        expect(notification.status).to eq(401)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with timeout error" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030")
        stub = stub_request(:get, work.pid).to_return(:status => [408])
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 408 for #{work.pid}", status: 408)
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("Net::HTTPRequestTimeOut")
        expect(notification.status).to eq(408)
        expect(stub).to have_been_requested
      end
    end

    context "handle URL" do
      it "get_handle_url" do
        work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://dx.plos.org/#{work.doi}"
        response = subject.get_handle_url(work.pid, work_id: work.id)
        expect(response).to eq(url)
        expect(Notification.count).to eq(0)
      end
    end

    context "persistent identifiers" do
      let(:work) { FactoryGirl.create(:work, :with_events, :doi => "10.1371/journal.pone.0000030") }

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
        expect(response).to eq(error: "Resource not found.", status: 404)
      end
    end

    context "missing metadata" do

      # Missing metadata should be added for any service, test via Crossref.
      # Need new example DOI

      # it "get_metadata with missing title" do
      #   doi = "10.1023/MISSING_TITLE_AND_ISSUED"
      #   response = subject.get_metadata(doi, "crossref")

      #   expect(response["DOI"]).to eq(doi)

      #   # If the title is empty in the response use the "(:unas)" value, per http://doi.org/10.5438/0010
      #   expect(response["title"]).to eq("(:unas)")

      #   # If the date issued is empty, it has to be *something*. 1970-01-01 is obvious.
      #   expect(response["issued"]).to eq("0000")
      # end

      it "get_metadata but error in response should not add title" do
        doi = "10.1023/XXXXXXXXX"
        response = subject.get_metadata(doi, "crossref")

        expect(response["DOI"]).to be_nil
        expect(response["title"]).to be_nil
      end
    end

    context "metadata" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

      let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0000030", pmid: "17183658") }
      let!(:publisher) { FactoryGirl.create(:publisher) }

      it "get_metadata crossref" do
        response = subject.get_metadata(work.doi, "crossref")
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
        expect(response["container-title"]).to eq("PLoS ONE")
        expect(response["issued"]).to eq("2006-12-20")
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq("340")
      end

      it "get_metadata datacite" do
        work = FactoryGirl.create(:work, doi: "10.6084/M9.FIGSHARE.156595")
        FactoryGirl.create(:publisher, name: "CDL.DIGSCI")
        response = subject.get_metadata(work.doi, "datacite")
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Uncovering Impact - Moving beyond the journal article and beyond the impact factor")
        expect(response["container-title"]).to eq("Figshare")
        expect(response["author"]).to eq([{"family"=>"Trends", "given"=>"Research"}, {"family"=>"Piwowar", "given"=>"Heather", "ORCID"=>"http://orcid.org/0000-0003-1613-5981"}])
        expect(response["issued"]).to eq("2013-02-13T14:46:00Z")
        expect(response["type"]).to eq("dataset")
        expect(response["publisher_id"]).to eq("CDL.DIGSCI")
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
        expect(response["issued"]).to eq("2006-12-20")
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq("340")
      end

      it "get_crossref_metadata with old DOI" do
        work = FactoryGirl.create(:work, doi: "10.1890/0012-9658(2006)87[2832:tiopma]2.0.co;2")
        response = subject.get_crossref_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("THE IMPACT OF PARASITE MANIPULATION AND PREDATOR FORAGING BEHAVIOR ON PREDATOR–PREY COMMUNITIES")
        expect(response["container-title"]).to eq("Ecology")
        expect(response["issued"]).to eq("2006-11")
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq("311")
      end

      it "get_crossref_metadata with date in future" do
        work = FactoryGirl.create(:work, doi: "10.1016/j.ejphar.2015.03.018")
        response = subject.get_crossref_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Paving the path to HIV neurotherapy: Predicting SIV CNS disease")
        expect(response["container-title"]).to eq("European Journal of Pharmacology")
        expect(response["published"]).to eq("2015-07")
        expect(response["type"]).to eq("article-journal")
        expect(response["publisher_id"]).to eq("78")
      end

      it "get_crossref_metadata with not found error" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_crossref_metadata("#{work.doi}x")
        expect(response).to eq(error: "Resource not found.", status: 404)
      end
    end

    context "datacite metadata" do
      before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 6, 25)) }

      let(:work) { FactoryGirl.create(:work, doi: "10.5061/DRYAD.8515") }

      it "get_datacite_metadata" do
        publisher = FactoryGirl.create(:publisher, name: "CDL.DRYAD")
        response = subject.get_datacite_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"]).to eq("Data from: A new malaria agent in African hominids")
        expect(response["container-title"]).to eq("Dryad Digital Repository")
        expect(response["author"]).to eq([{"family"=>"Ollomo", "given"=>"Benjamin"}, {"family"=>"Durand", "given"=>"Patrick"}, {"family"=>"Prugnolle", "given"=>"Franck"}, {"family"=>"Douzery", "given"=>"Emmanuel J. P."}, {"family"=>"Arnathau", "given"=>"Céline"}, {"family"=>"Nkoghe", "given"=>"Dieudonné"}, {"family"=>"Leroy", "given"=>"Eric"}, {"family"=>"Renaud", "given"=>"François"}])
        expect(response["issued"]).to eq("2011-02-01T17:32:02Z")
        expect(response["type"]).to eq("dataset")
        expect(response["publisher_id"]).to eq("CDL.DRYAD")
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
        expect(response).to eq(error: "Resource not found.", status:404)
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

    context "clean identifiers" do
      let(:url) { "http://journals.PLOS.org/plosone/article?id=10.1371%2Fjournal.pone.0000030&utm_source=FeedBurner#stuff" }

      it "get_normalized_url" do
        response = subject.get_normalized_url(url)
        expect(response).to eq("http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030")
      end

      it "get_normalized_url invalid url" do
        url = "article?id=10.1371%2Fjournal.pone.0000030"
        response = subject.get_normalized_url(url)
        expect(response).to be_nil
      end
    end
  end
end
