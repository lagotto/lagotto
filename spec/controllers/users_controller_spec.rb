require 'rails_helper'

describe UsersController, :type => :controller do

  describe ".safe_params" do
    context "with admin current user" do
      it "returns params with role key" do
        controller.stub(:current_user) { FactoryGirl.create(:admin_user) }
        controller.params[:user] = {role: 'admin'}
        expect(controller.send(:safe_params).has_key?(:role)).to be true
      end
    end

    context "with non-admin current user" do
      it "returns params without role key" do
        controller.stub(:current_user) { FactoryGirl.create(:user) }
        controller.params[:user] = { role: 'admin' }
        expect(controller.send(:safe_params).has_key?(:role)).to be false
      end
    end
  end
end
