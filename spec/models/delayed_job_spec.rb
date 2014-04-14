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

describe DelayedJob do

  before(:each) do
    Time.stub(:now).and_return(Time.mktime(2013, 9, 5))
  end

  let(:source) { FactoryGirl.create(:source, run_at: Time.zone.now) }

  subject { source }

  context "use background jobs" do
    let(:retrieval_statuses) { FactoryGirl.create_list(:retrieval_status, 10, source_id: source.id) }
    let(:rs_ids) { retrieval_statuses.map(&:id) }

    context "queue all articles" do
      it "queue" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate_limiting" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
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
        report = FactoryGirl.create(:disabled_source_report_with_admin_user)

        source.disable
        source.should be_disabled
        source.queue_all_articles.should == 0
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

        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 2)
        source.queue_all_articles(start_date: Date.today - 2.days, end_date: Date.today - 2.days).should == 0
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end
    end

    context "queue articles" do
      it "queue" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "only stale articles" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, scheduled_at: nil)
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "not queued articles" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id, queued_at: Time.zone.now)
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate-limiting" do
        rate_limiting = 5
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.rate_limiting = rate_limiting
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids[0...rate_limiting], source.id))
      end

      it "with job_batch_size" do
        job_batch_size = 5
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.job_batch_size = job_batch_size
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id))
      end

      it "with inactive source" do
        source.inactivate
        source.queue_all_articles.should == 0
        source.should be_inactive
      end

      it "with disabled source" do
        report = FactoryGirl.create(:disabled_source_report_with_admin_user)

        source.disable
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        source.should be_disabled
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with waiting source" do
        source.wait
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        source.should be_waiting
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with too many failed queries" do
        report = FactoryGirl.create(:disabled_source_report_with_admin_user)

        FactoryGirl.create_list(:alert, 10, source_id: source.id, updated_at: Time.zone.now - 10.minutes)
        source.max_failed_queries = 5
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        source.should_not be_disabled
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with queued jobs" do
        Delayed::Job.stub(:count).and_return(1)
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end
    end

    context "queue article jobs" do
      it "multiple articles" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "single article" do
        retrieval_status = FactoryGirl.create(:retrieval_status, source_id: source.id)
        Delayed::Job.stub(:enqueue).with(SourceJob.new([retrieval_status.id], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:perform).with(SourceJob.new([retrieval_status.id], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_article_jobs([retrieval_status.id]).should == 1
        Delayed::Job.expects(:enqueue).with(SourceJob.new([retrieval_status.id], source.id))
      end
    end

    context "job callbacks" do
      it "perform callback" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id))
      end

      it "perform callback without workers" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.workers = 0
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id)).once.returns(0)
      end

      it "perform callback without enough workers" do
        job_batch_size = 5
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids[0...job_batch_size], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:perform).with(SourceJob.new(rs_ids[job_batch_size..10], source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.job_batch_size = job_batch_size
        source.workers = 1
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id)).twice
        Delayed::Job.expects(:perform).with(SourceJob.new(rs_ids, source.id)).once
      end

      it "after callback" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        Delayed::Job.stub(:after).with(SourceJob.new(rs_ids, source.id), queue: source.name, run_at: Time.zone.now, priority: 3)
        source.queue_article_jobs(rs_ids).should == 10
        Delayed::Job.expects(:after).with(SourceJob.new(rs_ids, source.id))
      end
    end

    describe "check for failures" do

      let(:class_name) { "Net::HTTPRequestTimeOut" }
      before(:each) do
        FactoryGirl.create_list(:alert, 10, source_id: source.id, updated_at: Time.zone.now - 10.minutes, class_name: class_name)
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
