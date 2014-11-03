require 'rails_helper'

describe Worker do

  context "class methods" do
    subject { Worker }

    it { should respond_to :all }
    it { should respond_to :find }
    it { should respond_to :count }
    it { should respond_to :start }
    it { should respond_to :stop }
    it { should respond_to :monitor }
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
      subject.id.should_not be_nil
    end

    it "should have pid" do
      subject.pid.should_not be_nil
    end

    it "should have sleeping state" do
      subject.state.should eq("S (sleeping)")
    end

    it "should have memory" do
      subject.memory.should_not be_nil
    end

    it "should have created_at" do
      subject.created_at.should_not be_nil
    end
  end
end
