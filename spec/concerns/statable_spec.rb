require "rails_helper"

describe Source do

  subject { FactoryGirl.create(:source) }

  describe "states" do
    describe ":waiting" do
      it "should be an initial state" do
        subject.should be_waiting
      end

      it "should change to :working on :work" do
        subject.work
        subject.should be_working
      end

      it "should change to :inactive on :inactivate" do
        subject.should receive(:remove_queues)
        subject.inactivate
        subject.should be_inactive
      end

      it "should change to :disabled on :disable" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        subject.should be_disabled
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("TooManyErrorsBySourceError")
        alert.message.should eq("#{subject.display_name} has exceeded maximum failed queries. Disabling the source.")
        alert.source_id.should == subject.id
      end
    end

    describe ":working" do
      before(:each) { subject.work }

      it "should change to :inactive on :inactivate" do
        subject.should receive(:remove_queues)
        subject.inactivate
        subject.should be_inactive
      end

      it "should change to :disabled on :disable" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        subject.should be_disabled
        Alert.count.should == 1
        alert = Alert.first
        alert.class_name.should eq("TooManyErrorsBySourceError")
        alert.message.should eq("#{subject.display_name} has exceeded maximum failed queries. Disabling the source.")
        alert.source_id.should == subject.id
      end

      it "should change to :waiting on :wait" do
        subject.wait
        subject.should be_waiting
      end
    end

    describe ":inactive" do
      subject { FactoryGirl.create(:source, state_event: "install") }

      it "should change to :waiting on :activate" do
        subject.should be_inactive
        subject.activate
        subject.should be_waiting
      end

      describe "invalid source" do
        subject { FactoryGirl.create(:source, state_event: "install", url: "") }

        it "should not change to :waiting on :activate" do
          subject.activate
          subject.should be_inactive
          subject.errors.full_messages.first.should eq("Url can't be blank")
        end
      end
    end

    describe ":available" do
      before(:each) { subject.uninstall }

      it "should change to :inactive on :install" do
        subject.install
        subject.should be_inactive
      end
    end

    describe ":retired" do
      subject { FactoryGirl.create(:source, obsolete: true) }

      before(:each) do
        subject.uninstall
      end

      it "should change to :retired on :install" do
        subject.install
        subject.should be_retired
      end
    end
  end
end
