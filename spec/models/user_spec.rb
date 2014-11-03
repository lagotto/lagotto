require 'rails_helper'
require "cancan/matchers"

describe User, :type => :model do

  subject { FactoryGirl.create(:user) }

  it { is_expected.to validate_presence_of(:name) }

  context "describe admin role" do
    let(:user) { FactoryGirl.create(:user, :role => "admin") }

    it "admin can" do
      ability = Ability.new(user)
      expect(ability).to be_able_to(:manage, Alert.new)
    end
  end

  context "describe staff role" do
    let(:user) { FactoryGirl.create(:user, :role => "staff") }

    it "staff can" do
      ability = Ability.new(user)
      expect(ability).not_to be_able_to(:manage, Alert.new)
      expect(ability).to be_able_to(:read, Alert.new)
    end
  end

  context "describe user role" do
    let(:user) { FactoryGirl.create(:user, :role => "user") }

    it "user can" do
      ability = Ability.new(user)
      expect(ability).not_to be_able_to(:read, Alert.new)
    end
  end
end
