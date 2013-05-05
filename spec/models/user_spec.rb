require 'spec_helper'
require "cancan/matchers"

describe User do
  
  context "describe admin role" do
    let(:user) { FactoryGirl.create(:user, :role => "admin") }

    it "admin can" do
      ability = Ability.new(user)
      ability.should be_able_to(:manage, ErrorMessage.new)
    end
  end
  
  context "describe staff role" do
    let(:user) { FactoryGirl.create(:user, :role => "staff") }

    it "staff can" do
      ability = Ability.new(user)
      ability.should_not be_able_to(:manage, ErrorMessage.new)
      ability.should be_able_to(:read, ErrorMessage.new)
    end
  end
  
  context "describe user role" do
    let(:user) { FactoryGirl.create(:user, :role => "user") }

    it "user can" do
      ability = Ability.new(user)
      ability.should_not be_able_to(:read, ErrorMessage.new)
      ability.should be_able_to(:read, Article.new)
    end
  end
end