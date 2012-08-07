require 'spec_helper'

describe Group do
  
  before do
    @group = FactoryGirl.build(:group)
  end

  it { should have_many(:sources).dependent(:nullify) }
  
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

end