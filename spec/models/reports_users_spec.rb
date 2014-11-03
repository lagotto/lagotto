require 'rails_helper'

describe "Users to reports relationship" do

  let(:user) { FactoryGirl.create(:user, :role => "admin") }
  let(:report) { FactoryGirl.create(:report) }

  it "should recognise when a user has not signed up for any reports" do
    user.reports.count.should == 0
  end

  it "should handle a user who has signed up for a report" do
    user.reports << report
    user.reports.count.should == 1
  end

  it "should automatically know a reports user" do
    user.reports << report
    report.users.count.should == 1
  end
end
