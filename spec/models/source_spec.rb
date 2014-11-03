require 'rails_helper'

describe Source do

  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:priority).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:workers).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:timeout).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:wait_time).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:max_failed_queries).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:max_failed_query_time_interval).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:job_batch_size).only_integer.with_message("should be between 1 and 1000") }
  it { should validate_inclusion_of(:job_batch_size).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should validate_numericality_of(:rate_limiting).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_week).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_month).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_year).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_all).is_greater_than(0).only_integer.with_message("must be greater than 0") }

  describe "get_events_by_day" do
    before(:each) { Date.stub(:today).and_return(Date.new(2013, 9, 5)) }

    let(:article) { FactoryGirl.build(:article, :doi => "10.1371/journal.ppat.1000446", published_on: "2013-08-05") }

    it "should handle events" do
      events = [{ event_time: (Date.today - 2.weeks).to_datetime.utc.iso8601 },
                { event_time: (Date.today - 2.weeks).to_datetime.utc.iso8601 },
                { event_time: (Date.today - 1.week).to_datetime.utc.iso8601 }]
      subject.get_events_by_day(events, article).should eq([{:year=>2013, :month=>8, :day=>22, :total=>2}, {:year=>2013, :month=>8, :day=>29, :total=>1}])
    end

    it "should handle empty lists" do
      events = []
      subject.get_events_by_day(events, article).should eq([])
    end

    it "should handle events without event_time" do
      events = [{ }, { event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }]
      subject.get_events_by_day(events, article).should eq([{:year=>2013, :month=>8, :day=>5, :total=>1}])
    end
  end

  describe "get_events_by_month" do
    before(:each) { Date.stub(:today).and_return(Date.new(2013, 9, 5)) }

    it "should handle events" do
      events = [{ event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }, { event_time: (Date.today - 1.week).to_datetime.utc.iso8601 }]
      subject.get_events_by_month(events).should eq([{ year: 2013, month: 8, total: 2 }])
    end

    it "should handle empty lists" do
      events = []
      subject.get_events_by_month(events).should eq([])
    end

    it "should handle events without event_time" do
      events = [{ }, { event_time: (Date.today - 1.month).to_datetime.utc.iso8601 }]
      subject.get_events_by_month(events).should eq([{ year: 2013, month: 8, total: 1 }])
    end
  end
end
