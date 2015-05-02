require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "HTTP" do
    let(:work) { FactoryGirl.create(:work_with_events) }
    let(:url) { "http://127.0.0.1/api/v3/works/info:doi/#{work.doi}" }
    let(:data) { { "name" => "Fred" } }
    let(:post_data) { { "name" => "Jack" } }

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
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        clean_url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        url = "#{clean_url}/"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with jsessionid" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0000030;jsessionid=5362E4D61F1953ADA2CB3F746E58AAC2.f01t03"
        clean_url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(clean_url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with cookies" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1080/10629360600569196")
        url = "http://www.tandfonline.com/doi/abs/10.1080/10629360600569196"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url })
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/>" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_canonical.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <meta property='og:url'/>" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work_opengraph.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(url)
        expect(Alert.count).to eq(0)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with <link rel='canonical'/> mismatch" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        url = "http://www.plosone.org/article/info:doi/10.1371/journal.pone.0000030"
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
        stub = stub_request(:get, url).to_return(:status => 200, :headers => { 'Location' => url }, :body => File.read(fixture_path + 'work.html'))
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "Canonical URL mismatch: http://dx.plos.org/10.1371/journal.pone.0000030 for http://www.plosone.org/article/info:doi/#{work.doi}", status: 404)
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
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 302, :headers => { 'Location' => url })
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
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 404, :body => File.read(fixture_path + 'doi_not_found.html'))
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
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => 401)
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 401 for http://dx.doi.org/#{work.doi}", status: 401)
        expect(Alert.count).to eq(1)
        alert = Alert.first
        expect(alert.class_name).to eq("Net::HTTPUnauthorized")
        expect(alert.status).to eq(401)
        expect(stub).to have_been_requested
      end

      it "get_canonical_url with timeout error" do
        work = FactoryGirl.create(:work_with_events, :doi => "10.1371/journal.pone.0000030")
        stub = stub_request(:get, "http://dx.doi.org/#{work.doi}").to_return(:status => [408])
        response = subject.get_canonical_url(work.doi_as_url, work_id: work.id)
        expect(response).to eq(error: "the server responded with status 408 for http://dx.doi.org/#{work.doi}", status: 408)
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
      let(:work) { FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0000030") }

      it "get_metadata" do
        response = subject.get_metadata(work.doi)
        expect(response["DOI"]).to eq(work.doi)
        expect(response["title"].first).to eq("Triose Phosphate Isomerase Deficiency Is Caused by Altered Dimerization–Not Catalytic Inactivity–of the Mutant Enzymes")
        expect(response["issued"]).to eq("date-parts"=>[[2006, 12, 20]])
      end

      it "get_metadata with not found error" do
        ids = { "pmcid" => "PMC1762313", "pmid" => "17183658", "doi" => "10.1371/journal.pone.0000030", "versions" => [{ "pmcid" => "PMC1762313.1", "current" => "true" }] }
        response = subject.get_metadata("#{work.doi}x")
        expect(response).to eq(error: "Resource not found.", status: 404)
      end
    end
  end
end
