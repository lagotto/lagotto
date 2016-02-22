require 'rails_helper'

describe Relation, :type => :model do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  subject { FactoryGirl.create(:relation) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:related_work) }
  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:relation_type) }

  it { is_expected.to validate_presence_of(:work_id) }
  it { is_expected.to validate_presence_of(:related_work_id) }
  it { is_expected.to validate_presence_of(:relation_type_id) }

  describe "get_events_previous_month" do
    it "no months" do
      subject = FactoryGirl.create(:relation)
      expect(subject.get_events_previous_month).to eq("total" => 0)
    end

    it "current month" do
      subject = FactoryGirl.create(:relation, :with_crossref_current_month)
      expect(subject.get_events_previous_month).to eq("total" => 0)
    end

    it "last month" do
      subject = FactoryGirl.create(:relation, :with_crossref_last_month)
      expect(subject.get_events_previous_month).to eq("total" => 20)
    end
  end

  describe "get_events_current_month" do
    it "no days" do
      subject = FactoryGirl.create(:relation, :with_crossref)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "total" => 25)
    end

    it "current month" do
      subject = FactoryGirl.create(:relation, :with_crossref_current_month)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "total" => 20)
    end

    it "last month" do
      subject = FactoryGirl.create(:relation, :with_crossref_last_month)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "total" => 5)
    end
  end
end
