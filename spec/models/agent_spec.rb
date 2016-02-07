require 'rails_helper'

describe Agent, :type => :model, vcr: true do

  it { is_expected.to belong_to(:group) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:timeout).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:max_failed_queries).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { is_expected.to validate_numericality_of(:rate_limiting).is_greater_than(0).only_integer.with_message("must be greater than 0") }

  describe "get_events_by_day" do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    let(:work) { FactoryGirl.build(:work, :doi => "10.1371/journal.ppat.1000446", published_on: "2013-08-05") }

    it "should handle events" do
      time = Time.zone.now - 1.month
      time_two = Time.zone.now - 1.week
      events = [{ "timestamp" => time.utc.iso8601 },
                { "timestamp" => time.utc.iso8601 },
                { "timestamp" => time_two.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work.published_on)).to eq([{:year=>2013, :month=>8, :day=>5, :total=>2}, {:year=>2013, :month=>8, :day=>29, :total=>1}])
    end

    it "should handle empty lists" do
      events = []
      expect(subject.get_events_by_day(events, work.published_on)).to eq([])
    end

    it "should handle events without timestamp" do
      time = Time.zone.now - 1.month
      events = [{ }, { "timestamp" => time.utc.iso8601 }]
      expect(subject.get_events_by_day(events, work.published_on)).to eq([{:year=>2013, :month=>8, :day=>5, :total=>1}])
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

    subject { FactoryGirl.create(:agent) }

    it "no delay" do
      expect(subject.wait_time.to_i).to eq(1)
    end

    it "low rate-limiting" do
      subject = FactoryGirl.create(:agent_with_api_responses)
      subject.rate_limiting = 10
      expect(subject.wait_time.to_i).to eq(3599)
    end

    it "over rate-limiting" do
      subject = FactoryGirl.create(:agent_with_api_responses)
      subject.rate_limiting = 4
      expect(subject.wait_time.to_i).to eq(3599)
    end
  end

  describe "background jobs" do
    include ActiveJob::TestHelper

    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

    subject { FactoryGirl.create(:agent, run_at: Time.zone.now) }

    context "use background jobs" do
      let(:works) { FactoryGirl.create_list(:work, 10) }
      let(:ids) { works.map(&:id) }
      let(:job) { AgentJob }

      context "queue jobs" do
        it "queue" do
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(10)
        end

        it "queue single" do
          works = FactoryGirl.create_list(:work, 1)
          ids = works.map(&:id)
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(1)
        end

        it "only tracked works" do
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          work = FactoryGirl.create(:work, tracked: false)
          expect(subject.queue_jobs).to eq(10)
        end

        it "with rate_limiting" do
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          subject.rate_limiting = 5
          expect(subject.queue_jobs).to eq(10)
        end

        it "with inactive agent" do
          subject.inactivate
          expect(subject).to be_inactive
          expect(subject.queue_jobs).to eq(0)
        end

        it "with waiting agent" do
          subject.wait
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(10)
          expect(subject).to be_waiting
        end

        it "with disabled agent" do
          report = FactoryGirl.create(:fatal_error_report_with_admin_user)

          subject.disable
          expect(subject).to be_disabled
          expect(subject.queue_jobs).to eq(0)
        end

        it "with too many failed queries" do
          report = FactoryGirl.create(:fatal_error_report_with_admin_user)

          FactoryGirl.create_list(:notification, 10, agent_id: subject.id, updated_at: Time.zone.now - 10.minutes)
          subject.max_failed_queries = 5
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(10)
          expect(subject).not_to be_disabled
        end

        it "outside time interval" do
          works = FactoryGirl.create_list(:work, 10, :published_today)
          ids = works.map(&:id)

          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs(from_pub_date: Date.today - 2.days, until_pub_date: Date.today - 2.days)).to eq(0)
        end
      end

      context "job callbacks" do
        it "perform callback" do
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          allow(job).to receive(:perform).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(10)
        end

        it "after callback" do
          allow(job).to receive(:enqueue).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          allow(job).to receive(:after).with(AgentJob.new(ids, subject.id), queue: subject.queue, wait_until: Time.zone.now)
          expect(subject.queue_jobs).to eq(10)
        end
      end

      context "check for failures" do
        let(:class_name) { "Net::HTTPRequestTimeOut" }
        let!(:notifications) { FactoryGirl.create_list(:notification, 10, agent_id: subject.id, updated_at: Time.zone.now - 10.minutes, class_name: class_name) }

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

  context "collect_data" do
    let(:work) { FactoryGirl.create(:work, doi: "10.1371/journal.pone.0115074", year: 2014, month: 12, day: 16) }
    subject { FactoryGirl.create(:agent) }

    it "success" do
      response = subject.collect_data(work_id: work.id)
      expect(response["uuid"]).to be_present
      expect(response["message_type"]).to eq("citeulike")
      expect(response["source_token"]).to eq(subject.uuid)

      expect(Deposit.count).to eq(1)
      deposit = Deposit.first

      expect(deposit["message"]["works"].length).to eq(6)

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("citeulike")
      expect(event["work_id"]).to eq(work.pid)
    end

    it "success counter" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")
      subject = FactoryGirl.create(:counter)

      response = subject.collect_data(work_id: work.id)
      expect(response["message_type"]).to eq("counter")
      expect(response["source_token"]).to eq(subject.uuid)

      expect(Deposit.count).to eq(1)
      deposit = Deposit.first

      expect(deposit["message"]["works"]).to be_nil

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("counter")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success mendeley" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0008776")
      subject = FactoryGirl.create(:mendeley)
      body = File.read(fixture_path + 'mendeley.json')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)

      response = subject.collect_data(work_id: work.id)
      expect(response["uuid"]).to be_present
      expect(response["message_type"]).to eq("mendeley")
      expect(response["source_token"]).to eq(subject.uuid)

      expect(Deposit.count).to eq(1)
      deposit = Deposit.first

      expect(deposit["message"]["works"]).to be_nil

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("mendeley")
      expect(event["work_id"]).to eq(work.pid)

      expect(Deposit.count).to eq(1)
    end

    it "success crossref" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0053745")
      subject = FactoryGirl.create(:crossref)
      body = File.read(fixture_path + 'cross_ref.xml')
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:body => body)

      response = subject.collect_data(work_id: work.id)
      expect(response["uuid"]).to be_present
      expect(response["message_type"]).to eq("crossref")
      expect(response["source_token"]).to eq(subject.uuid)

      expect(Deposit.count).to eq(1)
      deposit = Deposit.first

      expect(deposit["message"]["works"].length).to eq(31)

      event = deposit["message"]["events"].first
      expect(event["source_id"]).to eq("crossref")
      expect(event["work_id"]).to eq(work.pid)
    end

    it "success no data" do
      work = FactoryGirl.create(:work, :doi => "10.1371/journal.pone.0116034")

      deposit = subject.collect_data(work_id: work.id)
      expect(deposit).to be_empty

      expect(Deposit.count).to eq(0)
    end

    it "error" do
      stub = stub_request(:get, subject.get_query_url(work_id: work.id)).to_return(:status => [408])
      deposit = subject.collect_data(work_id: work.id)
      expect(deposit).to be_empty

      expect(Deposit.count).to eq(0)
    end
  end
end
