require 'spec_helper'

describe User do
  
  it "should create a new instance given a valid attribute" do
    @user = FactoryGirl.create(:user)
  end
end