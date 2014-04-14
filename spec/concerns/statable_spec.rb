require 'spec_helper'

describe Source do

  before(:each) do
    Time.stub(:now).and_return(Time.mktime(2013, 9, 5))
  end

  let(:source) { FactoryGirl.create(:source, run_at: Time.zone.now) }

  subject { source }

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

      it 'should change to :working on :work' do
        source.work
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
