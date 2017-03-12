require 'rails_helper'

describe Event, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:event) }

  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:source_id) }
end
