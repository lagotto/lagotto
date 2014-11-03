require 'rails_helper'

describe Review, :type => :model do

  let(:review) { FactoryGirl.create(:review) }

  subject { review }

  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:state_id) }

end
