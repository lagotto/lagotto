require 'rails_helper'

describe Month, :type => :model do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:month) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:result) }

end
