require 'rails_helper'

describe Contribution, type: :model, vcr: true do
  let(:contribution) { FactoryGirl.create(:contribution) }

  subject { contribution }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:contributor) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:contributor_role) }

  it { is_expected.to validate_presence_of(:work_id) }
  it { is_expected.to validate_presence_of(:contributor_id) }
  it { is_expected.to validate_presence_of(:source_id) }
end
