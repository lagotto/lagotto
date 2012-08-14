require 'spec_helper'

describe User do
  
  before do
    @user = FactoryGirl.build(:user)
  end
  
  it { should validate_presence_of(:password) }
  it { should validate_confirmation_of(:password) }
  it { should ensure_length_of(:password).is_at_least(6) }
  
  # TODO make shoulda_matcher work
  #it { should validate_presence_of(:encrypted_password) }
  it "should set the encrypted password attribute" do
    @user.encrypted_password.should_not be_blank
  end
  
  it "should have a password attribute" do
    @user.should respond_to(:password)
  end

  it "should have a password confirmation attribute" do
    @user.should respond_to(:password_confirmation)
  end
    
  it "should have an encrypted password attribute" do
    @user.should respond_to(:encrypted_password)
  end
  
  it "should create a new instance given a valid attribute" do
    @user = FactoryGirl.create(:user)
  end
  
  it "should require an email address" do
    no_email_user = FactoryGirl.build(:user, :email => "")
    no_email_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = FactoryGirl.build(:user, :email => address)
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = FactoryGirl.build(:user, :email => address)
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    @user = FactoryGirl.create(:user)
    user_with_duplicate_email = FactoryGirl.build(:user)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    @user = FactoryGirl.create(:user)
    upcased_email = @user[:email].upcase
    user_with_duplicate_email = @user = FactoryGirl.build(:user, :email => upcased_email)
    user_with_duplicate_email.should_not be_valid
  end

end