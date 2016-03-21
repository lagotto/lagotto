require 'rails_helper'

describe Contributor, type: :model, vcr: true do
  let(:contributor) { FactoryGirl.create(:contributor) }

  subject { contributor }

  it { is_expected.to have_many(:works) }
  it { is_expected.to validate_presence_of(:pid) }
  it { is_expected.to validate_uniqueness_of(:pid) }

  context "validate orcid format" do
    it "0000-0002-1825-0097" do
      contributor = FactoryGirl.build(:contributor, :orcid => "0000-0002-1825-0097")
      expect(contributor).to be_valid
    end

    it "0000-0002-1825-009X" do
      contributor = FactoryGirl.build(:contributor, :orcid => "0000-0002-1825-009X")
      expect(contributor).to be_valid
    end

    it "http://orcid.org/0000-0002-1825-0097" do
      contributor = FactoryGirl.build(:contributor, :orcid => "http://orcid.org/0000-0002-1825-0097")
      expect(contributor).not_to be_valid
    end

    it "555-1212" do
      contributor = FactoryGirl.build(:contributor, :orcid => "555-1212")
      expect(contributor).not_to be_valid
    end
  end

  it 'short_pid' do
    expect(contributor.short_pid).to eq("orcid.org/0000-0002-0159-2197")
  end

  context "associations" do
    it "should create associated contributions" do
      expect(Contribution.count).to eq(0)
      @contributors = FactoryGirl.create_list(:contributor, 2, :with_works)
      expect(Contribution.count).to eq(10)
    end

    it "should delete associated contributions" do
      @contributors = FactoryGirl.create_list(:contributor, 2, :with_works)
      expect(Contribution.count).to eq(10)
      @contributors.each(&:destroy)
      expect(Contribution.count).to eq(0)
    end
  end
end
