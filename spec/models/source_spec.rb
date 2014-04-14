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
    Time.stub(:now).and_return(Time.mktime(2013, 9, 5))
  end

  let(:source) { FactoryGirl.create(:source, run_at: Time.zone.now) }

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
    describe ':working' do
      it 'should be an initial state' do
        source.should be_working
      end

      it 'should change to :inactive on :inactivate' do
        source.should receive(:remove_queues)
        source.inactivate
        source.should be_inactive
        source.run_at.should eq(Time.zone.now + 5.years)
      end

      it 'should change to :disabled on :disable' do
        report = FactoryGirl.create(:disabled_source_report_with_admin_user)

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
    end

    describe ':waiting' do
      let(:source) { FactoryGirl.create(:source) }

      before(:each) do
        source.stop_working
      end

      it 'should change to :working on :start_working' do
        source.start_working
        source.should be_working
      end

      it 'should change to :inactive on :inactivate' do
        source.should receive(:remove_queues)
        source.inactivate
        source.should be_inactive
        source.run_at.should eq(Time.zone.now + 5.years)
      end

      it 'should change to :disabled on :disable' do
        report = FactoryGirl.create(:disabled_source_report_with_admin_user)

        source.disable
        source.should be_disabled
        source.run_at.should eq(Time.zone.now + source.disable_delay)
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("TooManyErrorsBySourceError")
        alert.message.should eq("#{source.display_name} has exceeded maximum failed queries. Disabling the source.")
        alert.source_id.should == source.id
      end
    end

    describe ':inactive' do
      let(:source) { FactoryGirl.create(:source, state_event: 'install') }

      it 'should change to :working on :activate' do
        source.should be_inactive
        source.activate
        source.should be_working
        source.run_at.should eq(Time.zone.now)
      end

      describe 'invalid source' do
        let(:source) { FactoryGirl.create(:source, state_event: 'install', url: '') }

        it 'should not change to :working on :activate' do
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
      let(:source) { FactoryGirl.create(:source, obsolete: true) }

      before(:each) do
        source.uninstall
      end

      it 'should change to :retired on :install' do
        source.install
        source.should be_retired
      end
    end
  end
end
