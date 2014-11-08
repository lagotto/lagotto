require 'rails_helper'

describe DelayedJob, :type => :model do

  before(:each) { allow(Time).to receive(:now).and_return(Time.mktime(2013, 9, 5)) }

  let(:source) { FactoryGirl.create(:source, run_at: Time.zone.now) }

  subject { source }

  context "use background jobs" do
    let(:retrieval_statuses) { FactoryGirl.create_list(:retrieval_status, 10, source_id: source.id) }
    let(:rs_ids) { retrieval_statuses.map(&:id) }

    context "queue all articles" do
      it "queue" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
      end

      it "with rate_limiting" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        source.rate_limiting = 5
        expect(source.queue_all_articles).to eq(10)
      end

      it "with inactive source" do
        source.inactivate
        expect(source).to be_inactive
        expect(source.queue_all_articles).to eq(0)
      end

      it "with disabled source" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        source.disable
        expect(source).to be_disabled
        expect(source.queue_all_articles).to eq(0)
      end

      # it "within time interval" do
      #   retrieval_statuses = FactoryGirl.create_list(:retrieval_status, 10, :with_article_published_today, source_id: source.id)
      #   rs_ids = retrieval_statuses.map(&:id)

      #   Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 2 })
      #   source.queue_all_articles({ start_date: Time.zone.now, end_date: Time.zone.now }).should == 10
      #   Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      # end

      it "outside time interval" do
        retrieval_statuses = FactoryGirl.create_list(:retrieval_status, 10, :with_article_published_today, source_id: source.id)
        rs_ids = retrieval_statuses.map(&:id)

        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles(start_date: Date.today - 2.days, end_date: Date.today - 2.days)).to eq(0)
      end
    end

    context "queue articles" do
      it "queue" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
      end

      it "only stale articles" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, scheduled_at: Date.today + 1.day)
        expect(source.queue_all_articles).to eq(10)
      end

      it "not queued articles" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, queued_at: Time.zone.now)
        expect(source.queue_all_articles).to eq(10)
      end

      it "with rate-limiting" do
        rate_limiting = 5
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        source.rate_limiting = rate_limiting
        expect(source.queue_all_articles).to eq(10)
      end

      it "with job_batch_size" do
        job_batch_size = 5
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        source.job_batch_size = job_batch_size
        expect(source.queue_all_articles).to eq(10)
      end

      it "with inactive source" do
        source.inactivate
        expect(source.queue_all_articles).to eq(0)
        expect(source).to be_inactive
      end

      it "with disabled source" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        source.disable
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
        expect(source).to be_disabled
      end

      it "with waiting source" do
        source.wait
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
        expect(source).to be_waiting
      end

      it "with too many failed queries" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        FactoryGirl.create_list(:alert, 10, source_id: source.id, updated_at: Time.zone.now - 10.minutes)
        source.max_failed_queries = 5
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
        expect(source).not_to be_disabled
      end

      it "with queued jobs" do
        allow(Delayed::Job).to receive(:count).and_return(1)
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_all_articles).to eq(10)
      end
    end

    context "queue article jobs" do
      it "multiple articles" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_article_jobs(rs_ids)).to eq(10)
      end

      it "single article" do
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id)
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new([retrieval_status.id], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(SourceJob.new([retrieval_status.id], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_article_jobs([retrieval_status.id])).to eq(1)
      end
    end

    context "job callbacks" do
      it "perform callback" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_article_jobs(rs_ids)).to eq(10)
      end

      it "perform callback without workers" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        source.workers = 0
        expect(source.queue_article_jobs(rs_ids)).to eq(10)
      end

      it "perform callback without enough workers" do
        job_batch_size = 5
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:perform).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        source.job_batch_size = job_batch_size
        source.workers = 1
        expect(source.queue_article_jobs(rs_ids)).to eq(10)
      end

      it "after callback" do
        allow(Delayed::Job).to receive(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        allow(Delayed::Job).to receive(:after).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 5)
        expect(source.queue_article_jobs(rs_ids)).to eq(10)
      end
    end

    describe "check for failures" do

      let(:class_name) { "Net::HTTPRequestTimeOut" }
      before(:each) do
        FactoryGirl.create_list(:alert, 10, source_id: source.id, updated_at: Time.zone.now - 10.minutes, class_name: class_name)
      end

      it "few failed queries" do
        expect(source.check_for_failures).to be false
      end

      it "too many failed queries" do
        source.max_failed_queries = 5
        expect(source.check_for_failures).to be true
      end

      it "too many failed queries but they are too old" do
        source.max_failed_queries = 5
        source.max_failed_query_time_interval = 500
        expect(source.check_for_failures).to be false
      end
    end
  end
end
