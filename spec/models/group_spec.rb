require 'rails_helper'

describe Group, :type => :model do

  subject { FactoryGirl.create(:group) }

  it { is_expected.to have_many(:sources).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }

end
