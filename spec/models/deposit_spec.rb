require 'rails_helper'

describe Deposit, :type => :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:deposit) }

  it { is_expected.to validate_presence_of(:source_token) }
  it { is_expected.to validate_presence_of(:subj_id) }
  it { is_expected.to validate_presence_of(:source_id) }

  describe "attributes" do
    it "year" do
      expect(subject.year).to eq(2015)
    end

    it "month" do
      expect(subject.month).to eq(4)
    end
  end
end
