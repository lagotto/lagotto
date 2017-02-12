require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "HTTP" do
    let(:work) { FactoryGirl.create(:work) }
    let(:url) { "http://127.0.0.1/api/v3/works/info:doi/#{work.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

    context "get_doi_ra" do
      it "doi crossref" do
        doi = "10.1371/journal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:id]).to eq("crossref")
      end

      it "doi crossref escaped" do
        doi = "10.1371%2Fjournal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:id]).to eq("crossref")
      end

      it "doi datacite" do
        doi = "10.5061/dryad.8515"
        ra = subject.get_doi_ra(doi)
        expect(ra[:id]).to eq("datacite")
      end

      it "invalid DOI" do
        doi = "10.1371/xxx"
        expect(subject.get_doi_ra(doi)).to eq(:errors=>[{"DOI"=>"10.1371/xxx", "status"=>"Invalid DOI"}])
      end

      it "doi crossref cached prefix" do
        doi = "10.1371/journal.pone.0000030"
        ra = subject.get_doi_ra(doi)
        expect(ra[:id]).to eq("crossref")
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

      # HTTP DOIs
      it "http://doi.org" do
        id = "http://doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      it "http://dx.doi.org" do
        id = "http://dx.doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      # HTTPS DOIs
      it "https://doi.org" do
        id = "https://doi.org/10.1371/journal.pone.0000030"
        expect(subject.get_id_hash(id)).to eq(doi: "10.1371/JOURNAL.PONE.0000030")
      end

      it "https://dx.doi.org" do
        id = "https://dx.doi.org/10.1371/journal.pone.0000030"
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

      it "can't find id" do
        id = "xxx"
        expect(subject.get_id_hash(id)).to be_blank
      end
    end

    context "canonical URL" do
      it "get_canonical_url" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=#{work.doi_escaped}"
        response = subject.get_canonical_url(work.pid)
        expect(response).to eq(url: url)
      end

      it "get_canonical_url with trailing slash" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1080/10629360600569196", doi: "10.1080/10629360600569196")
        clean_url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        url = "#{clean_url}/"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url: clean_url)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with jsessionid" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0000030;jsessionid=5362E4D61F1953ADA2CB3F746E58AAC2.f01t03"
        clean_url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url: clean_url)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with cookies" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1080/10629360600569196", :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url: url)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/>" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, "http://doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_canonical.html'))
        response = subject.get_canonical_url(work.pid)
        expect(response).to eq(url: url)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <meta property='og:url'/>" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
        url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
        stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_opengraph.html'))
        response = subject.get_canonical_url(work.pid, work_id: work.id)
        expect(response).to eq(url: url)
        expect(stub).to have_been_requested
      end

      # it "get_canonical_url with <link rel='canonical'/> mismatch" do
      #   work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
      #   url = "http://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0000030"
      #   stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
      #   stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work.html'))
      #   response = subject.get_canonical_url(work.pid, work_id: work.id)
      #   expect(response).to eq(error: "Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for http://journals.plos.org/plosone/article?id=#{work.doi_escaped}", status: 404)
      #   expect(stub).to have_been_requested
      # end

      # it "get_canonical_url with landing page" do
      #   work = FactoryGirl.create(:work, :with_events, pid: "http://doi.org/10.3109/09286586.2014.926940", doi: "10.3109/09286586.2014.926940")
      #   url = "http://informahealthcare.com/action/cookieabsent"
      #   stub = stub_request(:get, work.pid).to_return(:status => 302, :headers => { 'Location' => url })
      #   stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
      #   response = subject.get_canonical_url(work.pid, work_id: work.id)
      #   expect(response).to eq(error: "DOI #{work.doi} could not be resolved", status: 404)
      #   expect(stub).to have_been_requested
      # end

      it "get_canonical_url with not found error" do
        work = FactoryGirl.create(:work, pid: "https://doi.org/10.1371/journal.pone.0000030", doi: "10.1371/journal.pone.0000030")
        stub = stub_request(:get, work.pid).to_return(:status => 404, :body => File.read(fixture_path + 'doi_not_found.html'))
        response = subject.get_canonical_url(work.pid)
        expect(response).to eq("status"=>404, "title"=>"Not found")
        expect(stub).to have_been_requested
      end

      it "get_canonical_url unauthorized error" do
        work = FactoryGirl.create(:work, pid: "https://doi.org/10.1371/journal.pone.0000030")
        stub = stub_request(:get, work.pid).to_return(:status => 401)
        response = subject.get_canonical_url(work.pid)
        expect(response).to eq("status"=>400, "title"=>"the server responded with status 401")
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with timeout error" do
        work = FactoryGirl.create(:work, pid: "https://doi.org/10.1371/journal.pone.0000030")
        stub = stub_request(:get, work.pid).to_return(:status => [408], body: "test")
        response = subject.get_canonical_url(work.pid)
        expect(response).to eq("status"=>408, "title"=>"Request timeout")
        expect(stub).to have_been_requested
      end
    end

    context "handle URL" do
      it "get_handle_url" do
        work = FactoryGirl.create(:work, pid: "http://doi.org/10.1371/journal.pone.0000030", :doi => "10.1371/journal.pone.0000030")
        url = "http://dx.plos.org/#{work.doi}"
        response = subject.get_handle_url(work.pid)
        expect(response).to eq(url: url)
      end
    end

    context "persistent identifiers" do
      let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000030") }

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
