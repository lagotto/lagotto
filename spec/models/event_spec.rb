require 'rails_helper'

describe Event, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }

  describe "get_events_yesterday" do
    it "no days" do
      subject = FactoryGirl.create(:event, :with_crossref)
      expect(subject.get_events_previous_day).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0)
    end

    it "today" do
      subject = FactoryGirl.create(:event, :with_crossref_today)
      expect(subject.get_events_previous_day).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0)
    end

    it "yesterday" do
      subject = FactoryGirl.create(:event, :with_crossref_yesterday)
      expect(subject.get_events_previous_day).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 20)
    end
  end

  describe "get_events_today" do
    it "no days" do
      subject = FactoryGirl.create(:event, :with_crossref)
      expect(subject.get_events_current_day).to eq("year" => 2015, "month" => 4, "day" => 8, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 25)
    end

    it "today" do
      subject = FactoryGirl.create(:event, :with_crossref_today)
      expect(subject.get_events_current_day).to eq("year" => 2015, "month" => 4, "day" => 8, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 20)
    end

    it "yesterday" do
      subject = FactoryGirl.create(:event, :with_crossref_yesterday)
      expect(subject.get_events_current_day).to eq("year" => 2015, "month" => 4, "day" => 8, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 5)
    end
  end

  describe "get_events_previous_month" do
    it "no months" do
      subject = FactoryGirl.create(:event)
      expect(subject.get_events_previous_month).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0)
    end

    it "current month" do
      subject = FactoryGirl.create(:event, :with_crossref_current_month)
      expect(subject.get_events_previous_month).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 0)
    end

    it "last month" do
      subject = FactoryGirl.create(:event, :with_crossref_last_month)
      expect(subject.get_events_previous_month).to eq("pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 20)
    end
  end

  describe "get_events_current_month" do
    it "no days" do
      subject = FactoryGirl.create(:event, :with_crossref)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 25)
    end

    it "current month" do
      subject = FactoryGirl.create(:event, :with_crossref_current_month)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 20)
    end

    it "last month" do
      subject = FactoryGirl.create(:event, :with_crossref_last_month)
      expect(subject.get_events_current_month).to eq("year" => 2015, "month" => 4, "pdf" => 0, "html" => 0, "readers" => 0, "comments" => 0, "likes" => 0, "total" => 5)
    end
  end
end
