require 'rails_helper'

describe Source, :type => :model, vcr: true do

  subject { FactoryGirl.create(:source) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
end
