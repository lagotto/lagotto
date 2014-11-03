require 'rails_helper'

describe "Users to reports relationship", :type => :model do

  let(:user) { FactoryGirl.create(:user, :role => "admin") }
  let(:report) { FactoryGirl.create(:report) }

  it "should recognise when a user has not signed up for any reports" do
    expect(user.reports.count).to eq(0)
  end

  it "should handle a user who has signed up for a report" do
    user.reports << report
    expect(user.reports.count).to eq(1)
  end

  it "should automatically know a reports user" do
    user.reports << report
    expect(report.users.count).to eq(1)
  end
end
