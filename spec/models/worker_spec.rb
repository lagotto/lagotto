require 'rails_helper'

describe Worker, :type => :model do

  context "class methods" do
    subject { Worker }

    it { is_expected.to respond_to :all }
    it { is_expected.to respond_to :find }
    it { is_expected.to respond_to :count }
    it { is_expected.to respond_to :start }
    it { is_expected.to respond_to :stop }
    it { is_expected.to respond_to :monitor }
  end

  context "instance methods" do

    before(:all) do
      Worker.start
    end

    after(:all) do
      Worker.stop
    end

    subject { Worker.all[0] }

    it "should have id" do
      expect(subject.id).not_to be_nil
    end

    it "should have pid" do
      expect(subject.pid).not_to be_nil
    end

    it "should have sleeping state" do
      expect(subject.state).to eq("S (sleeping)")
    end

    it "should have memory" do
      expect(subject.memory).not_to be_nil
    end

    it "should have created_at" do
      expect(subject.created_at).not_to be_nil
    end
  end
end
