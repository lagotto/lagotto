require 'rails_helper'

describe Relation, :type => :model do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:relation) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:related_work) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:relation_type) }
  it { is_expected.to belong_to(:month) }

  it { is_expected.to validate_presence_of(:work_id) }
  it { is_expected.to validate_presence_of(:related_work_id) }
  it { is_expected.to validate_presence_of(:relation_type_id) }
end
