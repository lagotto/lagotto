require 'rails_helper'

describe Review do

  let(:review) { FactoryGirl.create(:review) }

  subject { review }

  it { should validate_uniqueness_of(:name).scoped_to(:state_id) }

end
