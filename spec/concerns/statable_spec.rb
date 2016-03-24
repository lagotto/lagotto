require "rails_helper"

describe Agent do

  subject { FactoryGirl.create(:agent) }

  describe "states" do
    describe ":waiting" do
      it "should be an initial state" do
        expect(subject).to be_waiting
      end

      it "should change to :working on :work" do
        subject.work
        expect(subject).to be_working
      end

      it "should change to :inactive on :inactivate" do
        expect(subject).to receive(:remove_queues)
        subject.inactivate
        expect(subject).to be_inactive
      end

      it "should change to :disabled on :disable" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        expect(subject).to be_disabled
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("TooManyErrorsBySourceError")
        expect(notification.message).to eq("#{subject.title} has exceeded maximum failed queries. Disabling the agent.")
        expect(notification.source_id).to eq(subject.source_id)
      end
    end

    describe ":working" do
      before(:each) { subject.work }

      it "should change to :inactive on :inactivate" do
        expect(subject).to receive(:remove_queues)
        subject.inactivate
        expect(subject).to be_inactive
      end

      it "should change to :disabled on :disable" do
        report = FactoryGirl.create(:fatal_error_report_with_admin_user)

        subject.disable
        expect(subject).to be_disabled
        expect(Notification.count).to eq(1)
        notification = Notification.first
        expect(notification.class_name).to eq("TooManyErrorsBySourceError")
        expect(notification.message).to eq("#{subject.title} has exceeded maximum failed queries. Disabling the agent.")
        expect(notification.source_id).to eq(subject.source_id)
      end

      it "should change to :waiting on :wait" do
        subject.wait
        expect(subject).to be_waiting
      end
    end

    describe ":inactive" do
      subject { FactoryGirl.create(:agent, state_event: "install") }

      it "should change to :waiting on :activate" do
        expect(subject).to be_inactive
        subject.activate
        expect(subject).to be_waiting
      end

      describe "invalid agent" do
        subject { FactoryGirl.create(:counter, state_event: "install", url_private: "") }

        it "should not change to :waiting on :activate" do
          subject.activate
          expect(subject).to be_inactive
          expect(subject.errors.full_messages.first).to eq("Url private can't be blank")
        end
      end
    end

    describe ":available" do
      before(:each) { subject.uninstall }

      it "should change to :inactive on :install" do
        subject.install
        expect(subject).to be_inactive
      end
    end

    describe ":retired" do
      subject { FactoryGirl.create(:agent, obsolete: true) }

      before(:each) do
        subject.uninstall
      end

      it "should change to :retired on :install" do
        subject.install
        expect(subject).to be_retired
      end
    end
  end
end
