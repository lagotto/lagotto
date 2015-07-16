require 'rails_helper'

describe WorkType, :type => :model do

  subject { FactoryGirl.create(:work_type) }

  it { is_expected.to have_many(:works) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:title) }

end
