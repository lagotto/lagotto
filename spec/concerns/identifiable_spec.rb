require 'rails_helper'

describe Work, type: :model, vcr: true do

  context "from url" do
    let(:url) { "http://doi.org/10.5061/dryad.8515" }
    let(:doi) { "10.5061/DRYAD.8515" }

    it "doi_from_url" do
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_from_url https" do
      id = "https://doi.org/10.5061/dryad.8515"
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_from_url dx.doi.org" do
      id = "http://dx.doi.org/10.5061/dryad.8515"
      response = subject.doi_from_url(url)
      expect(response).to eq("10.5061/DRYAD.8515")
    end

    it "doi_as_url" do
      response = subject.doi_as_url(doi)
      expect(response).to eq("http://doi.org/10.5061/DRYAD.8515")
    end
  end
end
