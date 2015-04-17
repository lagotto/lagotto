require 'rails_helper'

describe RelationType, :type => :model do

  subject { FactoryGirl.create(:relation_type) }

  it { is_expected.to have_many(:relationships).dependent(:nullify) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_uniqueness_of(:title) }

end
