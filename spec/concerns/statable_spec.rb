require "rails_helper"

describe Event do

  subject { FactoryGirl.create(:event) }

  # describe "states" do
  #   describe ":waiting" do
  #     it "should be an initial state" do
  #       expect(subject).to be_waiting
  #     end

  #     it "should change to :working on :work" do
  #       subject.work
  #       expect(subject).to be_working
  #     end

  #     it "should change to :inactive on :inactivate" do
  #       expect(subject).to receive(:remove_queues)
  #       subject.inactivate
  #       expect(subject).to be_inactive
  #     end

  #     it "should change to :disabled on :disable" do
  #       report = FactoryGirl.create(:fatal_error_report_with_admin_user)

  #       subject.disable
  #       expect(subject).to be_disabled
  #     end
  #   end

  #   describe ":working" do
  #     before(:each) { subject.work }

  #     it "should change to :inactive on :inactivate" do
  #       expect(subject).to receive(:remove_queues)
  #       subject.inactivate
  #       expect(subject).to be_inactive
  #     end

  #     it "should change to :disabled on :disable" do
  #       subject.disable
  #       expect(subject).to be_disabled
  #     end

  #     it "should change to :waiting on :wait" do
  #       subject.wait
  #       expect(subject).to be_waiting
  #     end
  #   end

  #   describe ":available" do
  #     before(:each) { subject.uninstall }

  #     it "should change to :inactive on :install" do
  #       subject.install
  #       expect(subject).to be_inactive
  #     end
  #   end

  #   describe ":retired" do
  #     subject { FactoryGirl.create(:agent, obsolete: true) }

  #     before(:each) do
  #       subject.uninstall
  #     end

  #     it "should change to :retired on :install" do
  #       subject.install
  #       expect(subject).to be_retired
  #     end
  #   end
  # end
end
