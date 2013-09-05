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

  let(:source) { FactoryGirl.create(:source, run_at: Time.now ) }

  subject { source }

  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:workers).only_integer.with_message("should be between 1 and 10") }
  it { should ensure_inclusion_of(:workers).in_range(1..10).with_message("should be between 1 and 10") }
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

  it "stale_at should depend on article age" do
    #@source.articles << build(:article, :published_on => 1.day.ago)
    #@source.articles << build(:article, :published_on => 2.months.ago)
    #@source.articles << build(:article, :published_on => 3.years.ago)
  end

  context "use background jobs" do
    let(:retrieval_statuses) { FactoryGirl.create_list(:retrieval_status, 10) }
    let(:rs_ids) { retrieval_statuses.map(&:id) }

    context "queue all articles" do
      it "queue" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 1 })
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate_limiting" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 1 })
        source.rate_limiting = 5
        source.queue_all_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with inactive source" do
        source.active = false
        source.queue_all_articles.should == 0
      end

      it "with disabled source" do
        source.run_at = Time.zone.now + 1.hour
        source.queue_all_articles.should == 0
      end
    end

    context "queue articles" do
      it "queue" do
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "only stale articles" do
        retrieval_status = FactoryGirl.create(:retrieval_status, scheduled_at: Time.zone.now + 1.day)
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "not queued articles" do
        retrieval_status = FactoryGirl.create(:retrieval_status, queued_at: Time.zone.now)
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids, source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_stale_articles.should == 10
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids, source.id))
      end

      it "with rate-limiting" do
        rate_limiting = 5
        Delayed::Job.stub(:enqueue).with(SourceJob.new(rs_ids[0...rate_limiting], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.rate_limiting = rate_limiting
        source.queue_stale_articles.should == 5
        Delayed::Job.expects(:enqueue).with(SourceJob.new(rs_ids[0...rate_limiting], source.id))
      end

      it "with inactive source" do
        source.active = false
        source.queue_stale_articles.should == 0
        source.run_at.should eq(Time.zone.now + source.batch_time_interval)
      end

      it "with disabled source" do
        source.run_at = Time.zone.now + source.disable_delay
        source.queue_stale_articles.should == 0
        source.run_at.should eq(Time.zone.now + source.disable_delay)
      end

      it "with too many failed queries" do
        FactoryGirl.create_list(:alert, 10, { source_id: source.id, updated_at: Time.zone.now - 10.minutes })
        source.max_failed_queries = 5
        source.queue_stale_articles.should == 0
        source.run_at.should eq(Time.zone.now + source.disable_delay)
      end

      it "with queued jobs" do
        Delayed::Job.stub(:count).with('id', :conditions => ["queue = ?", source.name]).and_return(1)
        source.queue_stale_articles.should == 0
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
        retrieval_status = FactoryGirl.create(:retrieval_status)
        Delayed::Job.stub(:enqueue).with(SourceJob.new([retrieval_status.id], source.id), { queue: source.name, run_at: Time.zone.now, priority: 3 })
        source.queue_article_jobs([retrieval_status.id]).should == 1
        Delayed::Job.expects(:enqueue).with(SourceJob.new([retrieval_status.id], source.id))
      end
    end

    context "check for failures" do

      let(:class_name) { "Net::HTTPRequestTimeOut" }
      before(:each) do
        FactoryGirl.create_list(:alert, 10, { source_id: source.id,
                                              updated_at: Time.zone.now - 10.minutes,
                                              class_name: class_name })
      end

      it "few failed queries" do
        source.check_for_failures.should be_true
        source.run_at.should < Time.zone.now
        Alert.count.should == 10
      end

      it "too many failed queries" do
        source.max_failed_queries = 5
        source.check_for_failures.should be_false
        source.run_at.should > Time.zone.now
        Alert.count.should == 11

        alert = Alert.where("class_name != '#{class_name}'").first
        alert.class_name.should eq("TooManyErrorsBySourceError")
        alert.message.should eq("#{source.display_name} has exceeded maximum failed queries. Disabling the source.")
        alert.source_id.should == source.id
      end

      it "too many failed queries but they are too old" do
        source.max_failed_queries = 5
        source.max_failed_query_time_interval = 500
        source.check_for_failures.should be_true
        source.run_at.should < Time.zone.now
        Alert.count.should == 10
      end
    end
  end
end
