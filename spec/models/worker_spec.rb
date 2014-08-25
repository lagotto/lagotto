# encoding: UTF-8

require 'spec_helper'

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

    its(:id) { should_not be_nil }
    its(:pid) { should_not be_nil }
    its(:state) { should eq("S (sleeping)") }
    its(:memory) { should_not be_nil }
    its(:created_at) { should_not be_nil }
  end

end
