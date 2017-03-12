require 'rails_helper'

describe Source, type: :model, vcr: true do

  let(:source) { FactoryGirl.create(:source) }

  subject { source }

  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
end
