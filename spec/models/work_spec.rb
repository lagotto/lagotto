require 'rails_helper'

describe Work, type: :model, vcr: true do

  let(:work) { FactoryGirl.create(:work, pid: "http://doi.org/10.5555/12345678") }

  subject { work }

  context "validate pid" do
    it "https://doi.org/10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "https://doi.org/10.5555/12345678")
      expect(work).to be_valid
    end

    it "http://doi.org/10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "http://doi.org/10.5555/12345678")
      expect(work).to be_valid
    end

    it "https://dx.doi.org/10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "https://dx.doi.org/10.5555/12345678")
      expect(work).to be_valid
    end

    it "http://dx.doi.org/10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "http://dx.doi.org/10.5555/12345678")
      expect(work).to be_valid
    end

    it "doi:10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "doi:10.5555/12345678")
      expect(work).to be_valid
    end

    it "10.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "10.5555/12345678")
      expect(work).to be_valid
    end

    it "10.13039/100000001" do
      work = FactoryGirl.build(:work, pid: "10.13039/100000001")
      expect(work).to be_valid
    end

    it "10.1386//crre.4.1.53_1" do
      work = FactoryGirl.build(:work, pid: " 10.1386//crre.4.1.53_1")
      expect(work).not_to be_valid
    end

    it "10.555/12345678" do
      work = FactoryGirl.build(:work, pid: "10.555/12345678")
      expect(work).not_to be_valid
    end

    it "8.5555/12345678" do
      work = FactoryGirl.build(:work, pid: "8.5555/12345678")
      expect(work).not_to be_valid
    end

    it "10.asdf/12345678" do
      work = FactoryGirl.build(:work, pid: "10.asdf/12345678")
      expect(work).not_to be_valid
    end

    it "10.5555" do
      work = FactoryGirl.build(:work, pid: "10.5555")
      expect(work).not_to be_valid
    end

    it "http://example.com/1234" do
      work = FactoryGirl.build(:work, pid: "http://example.com/1234")
      expect(work).to be_valid
    end

    it "https://example.com/1234" do
      work = FactoryGirl.build(:work, pid: "http://example.com/1234")
      expect(work).to be_valid
    end

    it "ftp://example.com/1234" do
      work = FactoryGirl.build(:work, pid: "ftp://example.com/1234")
      expect(work).not_to be_valid
    end

    it "http://" do
      work = FactoryGirl.build(:work, pid: "http://")
      expect(work).not_to be_valid
    end

    it "asdfasdfasdf" do
      work = FactoryGirl.build(:work, pid: "asdfasdfasdf")
      expect(work).not_to be_valid
    end
  end

  context "set provider" do
    it "crossref" do
      work = FactoryGirl.build(:work, pid: "https://doi.org/10.7554/elife.01567", provider_id: nil)
      expect(work).to be_valid
      expect(work.provider_id).to eq("crossref")
    end

    it "datacite" do
      work = FactoryGirl.build(:work, pid: "https://doi.org/10.5061/dryad.8515", provider_id: nil)
      expect(work).to be_valid
      expect(work.provider_id).to eq("datacite")
    end
  end
end
