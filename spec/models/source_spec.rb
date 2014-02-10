# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

describe Source do

  before(:each) do
    Time.stub(:now).and_return(Time.mktime(2013,9,5))
  end

  let(:source) { FactoryGirl.create(:source, run_at: Time.zone.now ) }

  subject { source }

  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:workers).only_integer.with_message("should be between 1 and 20") }
  it { should ensure_inclusion_of(:workers).in_range(1..20).with_message("should be between 1 and 20") }
  it { should validate_numericality_of(:timeout).only_integer.with_message("should be between 1 and 3600") }
  it { should ensure_inclusion_of(:timeout).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_numericality_of(:wait_time).only_integer.with_message("should be between 1 and 3600") }
  it { should ensure_inclusion_of(:wait_time).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_numericality_of(:max_failed_queries).only_integer.with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:max_failed_queries).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should validate_numericality_of(:max_failed_query_time_interval).only_integer.with_message("should be between 1 and 864000") }
  it { should ensure_inclusion_of(:max_failed_query_time_interval).in_range(1..864000).with_message("should be between 1 and 864000") }
  it { should validate_numericality_of(:job_batch_size).only_integer.with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:job_batch_size).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should validate_numericality_of(:batch_time_interval).only_integer.with_message("should be between 1 and 86400") }
  it { should ensure_inclusion_of(:batch_time_interval).in_range(1..86400).with_message("should be between 1 and 86400") }
  it { should ensure_inclusion_of(:rate_limiting).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_week).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_week).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_month).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_month).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_year).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_year).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_all).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_all).in_range(1..2678400).with_message("should be between 1 and 2678400") }

  describe 'states' do
    describe ':queueing' do
      it 'should be an initial state' do
        source.should be_queueing
      end

      it 'should change to :waiting on :stop_working' do
        source.stop_working
        source.should be_waiting
      end
    end

    describe ':working' do
      before(:each) do
        source.start_working
      end

      it 'should change to :inactive on :inactivate' do
        source.should receive(:remove_queues)
        source.inactivate
        source.should be_inactive
        source.run_at.should eq(Time.zone.now + 5.years)
      end

      it 'should change to :disabled on :disable' do
        source.disable
        source.should be_disabled
        source.run_at.should eq(Time.zone.now + source.disable_delay)
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("TooManyErrorsBySourceError")
        alert.message.should eq("#{source.display_name} has exceeded maximum failed queries. Disabling the source.")
        alert.source_id.should == source.id
      end

      it 'should change to :waiting on :stop_working' do
        source.stop_working
        source.should be_waiting
      end

      it 'should change to :idle on :stop_working if not queueable' do
        source.queueable = false
        source.stop_working
        source.should be_idle
      end

      it 'should change to :queueing on :start_queueing' do
        source.should receive(:add_queue)
        source.start_queueing
        source.should be_queueing
      end

      it 'should not change to :queueing on :start_queueing if not queueable' do
        source.queueable = false
        source.should_not receive(:add_queue)
        source.start_queueing
        source.should_not be_queueing
        source.should be_working
      end
    end

    describe ':idle' do
      let(:source) { FactoryGirl.create(:source, queueable: false ) }

      it 'should be an initial state for sources that cant be queued' do
        source.should be_idle
      end

      it 'should change to :working on :start_working' do
        source.start_working
        source.should be_working
      end
    end

    describe ':inactive' do
      let(:source) { FactoryGirl.create(:source, state_event: 'install' ) }

      it 'should change to :queuing on :activate' do
        source.should be_inactive
        source.activate
        source.should be_queueing
        source.run_at.should eq(Time.zone.now)
      end

      describe 'invalid source' do
        let(:source) { FactoryGirl.create(:source, state_event: 'install', url: '' ) }

        it 'should not change to :queuing on :activate' do
          source.activate
          source.should be_inactive
          source.errors.full_messages.first.should eq("Url can't be blank")
        end
      end
    end

    describe ':available' do
      before(:each) do
        source.uninstall
      end

      it 'should change to :inactive on :install' do
        source.install
        source.should be_inactive
        source.run_at.should eq(Time.zone.now + 5.years)
      end
    end

    describe ':retired' do
      let(:source) { FactoryGirl.create(:source, obsolete: true ) }

      before(:each) do
        source.uninstall
      end

      it 'should change to :retired on :install' do
        source.install
        source.should be_retired
      end
    end
  end

  context "use background jobs" do
    let(:retrieval_statuses) { FactoryGirl.create_list(:retrieval_status, 10, source_id: source.id) }
    let(:rs_ids) { retrieval_statuses.map(&:id) }

    context "queue all articles" do
      it "queue" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 2 })
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate_limiting" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 2 })
        source.rate_limiting = 5
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with inactive source" do
        source.inactivate
        source.should be_inactive
        source.queue_all_articles.should == 0
      end

      it "with disabled source" do
        source.disable
        source.should be_disabled
        source.queue_all_articles.should == 0
      end
    end

    context "queue articles" do
      it "queue" do
        source.should be_queueing
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 0 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "only stale articles" do
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, scheduled_at: nil)
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "not queued articles" do
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, queued_at: Time.zone.now)
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate-limiting" do
        rate_limiting = 5
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...rate_limiting], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.rate_limiting = rate_limiting
        source.queue_stale_articles.should == 5
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids[0...rate_limiting], source.id))
      end

      it "with job_batch_size" do
        job_batch_size = 5
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.job_batch_size = job_batch_size
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id))
      end

      it "with inactive source" do
        source.inactivate
        source.queue_stale_articles.should == 0
        source.should be_inactive
        source.run_at.should eq(Time.zone.now + 5.years)
      end

      it "with disabled source" do
        source.disable
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 0 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with waiting source" do
        source.start_waiting
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        source.should be_working
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with too many failed queries" do
        FactoryGirl.create_list(:alert, 10, { source_id: source.id, updated_at: Time.zone.now - 10.minutes })
        source.max_failed_queries = 5
        source.queue_stale_articles.should == 0
        source.should be_disabled
        source.run_at.should eq(Time.zone.now + source.disable_delay)
      end

      it "with queued jobs" do
        Delayed::Job.stub(:count).and_return(1)
        source.queue_stale_articles.should == 0
        source.should be_waiting
        source.run_at.should eq(Time.zone.now + source.wait_time)
      end
    end

    context "queue article jobs" do
      it "multiple articles" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "single article" do
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id)
        Delayed::Job.stub(:enqueue).with(SourceJob.new([retrieval_status.id], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        Delayed::Job.stub(:perform).with(SourceJob.new([retrieval_status.id], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_article_jobs([retrieval_status.id]).should == 1
        Delayed::Job.expects(:enqueue).with(SourceJob.new([retrieval_status.id], source.id))
      end
    end

    context "job callbacks" do
      it "perform callback" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id))
      end

      # it "perform callback without workers" do
      #   Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   source.workers = 0
      #   source.queue_article_jobs(rs_ids).should == 0
      #   Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id))
      # end

      # it "perform callback without enough workers" do
      #   job_batch_size = 5
      #   Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
      #   source.job_batch_size = job_batch_size
      #   source.workers = 1
      #   source.queue_article_jobs(rs_ids).should == 5
      #   Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id))
      # end

      it "after callback" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        Delayed::Job.stub(:after).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:after).with(SourceJob.new(rs_ids, source.id))
      end
    end

    context "queue callbacks" do
      it "perform callback" do
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:perform).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        source.add_queue
        Delayed::Job.expects(:perform).with(QueueJob.new(source.id))
      end

      it "after callback" do
        Delayed::Job.stub(:enqueue).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        Delayed::Job.stub(:after).with(QueueJob.new(source.id), { queue: "#{source.name}-queue", run_at: Time.zone.now, priority: 2 })
        source.add_queue
        Delayed::Job.expects(:after).with(QueueJob.new(source.id))
      end
    end

    describe "check for failures" do

      let(:class_name) { "Net::HTTPRequestTimeOut" }
      before(:each) do
        FactoryGirl.create_list(:alert, 10, { source_id: source.id,
                                              updated_at: Time.zone.now - 10.minutes,
                                              class_name: class_name })
      end

      it "few failed queries" do
        source.check_for_failures.should be_false
      end

      it "too many failed queries" do
        source.max_failed_queries = 5
        source.check_for_failures.should be_true
      end

      it "too many failed queries but they are too old" do
        source.max_failed_queries = 5
        source.max_failed_query_time_interval = 500
        source.check_for_failures.should be_false
      end
    end
  end
end