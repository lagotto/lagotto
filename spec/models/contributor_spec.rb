require 'rails_helper'

describe Contributor, type: :model, vcr: true do
  let(:contributor) { FactoryGirl.create(:contributor) }

  subject { contributor }

  it { is_expected.to have_many(:works) }
  it { is_expected.to validate_uniqueness_of(:pid) }
  it { is_expected.to validate_presence_of(:pid) }

  it 'short_pid' do
    expect(contributor.short_pid).to eq("orcid.org/0000-0002-0159-2197")
  end
end
