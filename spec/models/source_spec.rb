require 'rails_helper'

describe Source, :type => :model do

  it { is_expected.to belong_to(:group) }
  it { is_expected.to have_many(:retrieval_statuses).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:timeout).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:max_failed_queries).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:rate_limiting).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:staleness_week).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:staleness_month).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:staleness_year).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:staleness_all).is_greater_than(0).only_integer.with_message("must be greater than 0") }

  describe "get_events_by_day" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.ppat.1000446", published_on: "2013-08-05") }

    it "should handle events" do
      time = Time.zone.now - 1.month
      time_two = Time.zone.now - 1.week
      events = [{ "timestamp" => time.utc.iso8601 },
                { "timestamp" => time.utc.iso8601 },
                { "timestamp" => time_two.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work)).to eq([{:year=>2013, :month=>8, :day=>5, :total=>2}, {:year=>2013, :month=>8, :day=>29, :total=>1}])
    end

    it "should handle empty lists" do
      events = []
      expect(subject.get_events_by_day(events, work)).to eq([])
    end

    it "should handle events without timestamp" do
      time = Time.zone.now - 1.month
      events = [{ }, { "timestamp" => time.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work)).to eq([{:year=>2013, :month=>8, :day=>5, :total=>1}])
    end
  end

  describe "get_events_by_month" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    it "should handle events" do
      time = Time.zone.now - 1.month
      time_two = Time.zone.now - 1.week
      events = [{ "timestamp" => time.utc.iso8601 }, { "timestamp" => time_two.utc.iso8601 }]
      expect(subject.get_events_by_month(events)).to eq([{ year: 2013, month: 8, total: 2 }])
    end

    it "should handle empty lists" do
      events = []
      expect(subject.get_events_by_month(events)).to eq([])
    end

    it "should handle events without dates" do
      time = Time.zone.now - 1.month
      events = [{ }, { "timestamp" => time.utc.iso8601 }]
      expect(subject.get_events_by_month(events)).to eq([{ year: 2013, month: 8, total: 1 }])
    end
  end

  describe "wait_time" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    subject { FactoryGirl.create(:source) }

    it "no delay" do
      expect(subject.wait_time.to_i).to eq(1)
    end

    it "low rate-limiting" do
      subject = FactoryGirl.create(:source_with_api_responses)
      subject.rate_limiting = 10
      expect(subject.wait_time.to_i).to eq(3599)
    end

    it "over rate-limiting" do
      subject = FactoryGirl.create(:source_with_api_responses)
      subject.rate_limiting = 4
      expect(subject.wait_time.to_i).to eq(3599)
    end
  end

  describe "manage retrieval_statuses" do
    subject { FactoryGirl.create(:source) }

    it "should create retrievals for new works" do
      expect(subject.retrieval_statuses.count).to eq(0)
      works = FactoryGirl.create_list(:work, 3)
      expect(subject.retrieval_statuses.count).to eq(3)
    end

    it "should create retrievals for new source" do
      expect(subject.retrieval_statuses.count).to eq(0)
      works = FactoryGirl.create_list(:work, 3)
      expect(subject.retrieval_statuses.count).to eq(3)
    end

    # it "should create retrievals" do
    #   FactoryGirl.create_list(:work, 3)
    #   expect(subject.retrieval_statuses.count).to eq(0)
    #   subject.create_retrievals
    #   expect(subject.retrieval_statuses.count).to eq(3)
    # end

    it "should remove all retrievals" do
      FactoryGirl.create_list(:retrieval_status, 3)
      expect(subject.retrieval_statuses.count).to eq(3)
      subject.remove_all_retrievals
      expect(subject.retrieval_statuses.count).to eq(0)
    end
  end

  describe "background jobs" do
    include ActiveJob::TestHelper

    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    subject { FactoryGirl.create(:source, run_at: Time.zone.now) }

    context "use background jobs" do
      let(:retrieval_statuses) { FactoryGirl.create_list(:retrieval_status, 10, source_id: subject.id) }
      let(:rs_ids) { retrieval_statuses.map(&:id) }
      let(:job) { SourceJob }

      context "queue all works" do
        it "queue" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
        end

        it "with rate_limiting" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          subject.rate_limiting = 5
          expect(subject.queue_all_works).to eq(10)
        end

        it "with inactive source" do
          subject.inactivate
          expect(subject).to be_inactive
          expect(subject.queue_all_works).to eq(0)
        end

        it "with disabled source" do
          report = FactoryGirl.create(:fatal_error_report_with_admin_user)

          subject.disable
          expect(subject).to be_disabled
          expect(subject.queue_all_works).to eq(0)
        end

        it "outside time interval" do
          retrieval_statuses = FactoryGirl.create_list(:retrieval_status, 10, :with_work_published_today, source_id: subject.id)
          rs_ids = retrieval_statuses.map(&:id)

          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works(start_date: Date.today - 2.days, end_date: Date.today - 2.days)).to eq(0)
        end
      end

      context "queue works" do
        it "queue" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
        end

        it "only stale works" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          retrieval_status = FactoryGirl.create(:retrieval_status, source_id: subject.id, scheduled_at: Date.today + 1.day)
          expect(subject.queue_all_works).to eq(10)
        end

        it "not queued works" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          retrieval_status = FactoryGirl.create(:retrieval_status, source_id: subject.id, queued_at: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
        end

        it "with rate-limiting" do
          rate_limiting = 5
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          subject.rate_limiting = rate_limiting
          expect(subject.queue_all_works).to eq(10)
        end

        it "with inactive source" do
          subject.inactivate
          expect(subject.queue_all_works).to eq(0)
          expect(subject).to be_inactive
        end

        it "with disabled subject" do
          report = FactoryGirl.create(:fatal_error_report_with_admin_user)

          subject.disable
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
          expect(subject).to be_disabled
        end

        it "with waiting source" do
          subject.wait
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
          expect(subject).to be_waiting
        end

        it "with too many failed queries" do
          report = FactoryGirl.create(:fatal_error_report_with_admin_user)

          FactoryGirl.create_list(:alert, 10, source_id: subject.id, updated_at: Time.zone.now - 10.minutes)
          subject.max_failed_queries = 5
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
          expect(subject).not_to be_disabled
        end

        it "with queued jobs" do
          allow(job).to receive(:count).and_return(1)
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_all_works).to eq(10)
        end
      end

      context "queue work jobs" do
        it "multiple works" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_work_jobs(rs_ids)).to eq(10)
        end

        it "single work" do
          retrieval_status = FactoryGirl.create(:retrieval_status, source_id: subject.id)
          allow(job).to receive(:enqueue).with(SourceJob.new([retrieval_status.id], subject.id), queue: subject.name, wait_until: Time.zone.now)
          allow(job).to receive(:perform).with(SourceJob.new([retrieval_status.id], subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_work_jobs([retrieval_status.id])).to eq(1)
        end
      end

      context "job callbacks" do
        it "perform callback" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          allow(job).to receive(:perform).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_work_jobs(rs_ids)).to eq(10)
        end

        it "after callback" do
          allow(job).to receive(:enqueue).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          allow(job).to receive(:after).with(SourceJob.new(rs_ids, subject.id), queue: subject.name, wait_until: Time.zone.now)
          expect(subject.queue_work_jobs(rs_ids)).to eq(10)
        end
      end

      describe "check for failures" do

        let(:class_name) { "Net::HTTPRequestTimeOut" }
        before(:each) do
          FactoryGirl.create_list(:alert, 10, source_id: subject.id, updated_at: Time.zone.now - 10.minutes, class_name: class_name)
        end

        it "few failed queries" do
          expect(subject.check_for_failures).to be false
        end

        it "too many failed queries" do
          subject.max_failed_queries = 5
          expect(subject.check_for_failures).to be true
        end
      end
    end
  end
end
