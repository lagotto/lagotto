require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "from url" do
    let(:url) { "http://doi.org/10.5061/dryad.8515" }

    it "doi_from_url" do
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_from_url https" do
      url = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_from_url dx.doi.org" do
      url = "http://dx.doi.org/10.5061/dryad.8515"
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_from_url not a doi" do
      url = "https://handle.net/10.5061/dryad.8515"
      response = subject.doi_from_url(url)
      expect(response).to be_nil
    end

    it "orcid_from_url" do
      url = "http://orcid.org/0000-0002-2590-225X"
      response = subject.orcid_from_url(url)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid" do
      orcid = "http://orcid.org/0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid id" do
      orcid = "0000-0002-2590-225X"
      response = subject.validate_orcid(orcid)
      expect(response).to eq("0000-0002-2590-225X")
    end

    it "validate_orcid wrong id" do
      orcid = "0000 0002 1394 3097"
      response = subject.validate_orcid(orcid)
      expect(response).to be_nil
    end

    it "github_from_url release" do
      url = "https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry/tree/v0.1"
      response = subject.github_from_url(url)
      expect(response).to eq(owner: "Troy-Wilson", repo: "ASV-Autonomous-Bathymetry", release: "v0.1")
    end

    it "github_from_url repo" do
      url = "https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry"
      response = subject.github_from_url(url)
      expect(response).to eq(owner: "Troy-Wilson", repo: "ASV-Autonomous-Bathymetry")
    end

    it "github_from_url owner" do
      url = "https://github.com/Troy-Wilson"
      response = subject.github_from_url(url)
      expect(response).to eq(owner: "Troy-Wilson")
    end

    it "github_release_from_url" do
      url = "https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry/tree/v0.1"
      response = subject.github_release_from_url(url)
      expect(response).to eq("v0.1")
    end

    it "github_repo_from_url" do
      url = "https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry/tree/v0.1"
      response = subject.github_repo_from_url(url)
      expect(response).to eq("ASV-Autonomous-Bathymetry")
    end

    it "github_owner_from_url" do
      url = "https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry/tree/v0.1"
      response = subject.github_owner_from_url(url)
      expect(response).to eq("Troy-Wilson")
    end
  end

  context "to url" do
    let(:doi) { "10.5061/DRYAD.8515" }
    let(:github_hash) {{ owner: "Troy-Wilson", repo: "ASV-Autonomous-Bathymetry", release: "v0.1" }}

    it "doi_as_url" do
      response = subject.doi_as_url(doi)
      expect(response).to eq("https://doi.org/10.5061/DRYAD.8515")
    end

    it "github_as_owner_url" do
      response = subject.github_as_owner_url(github_hash)
      expect(response).to eq("https://github.com/Troy-Wilson")
    end

    it "github_as_repo_url" do
      response = subject.github_as_repo_url(github_hash)
      expect(response).to eq("https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry")
    end

    it "github_as_release_url" do
      response = subject.github_as_release_url(github_hash)
      expect(response).to eq("https://github.com/Troy-Wilson/ASV-Autonomous-Bathymetry/tree/v0.1")
    end
  end
end
