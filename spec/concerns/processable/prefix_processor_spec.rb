require "rails_helper"

describe Deposit, type: :model, vcr: true do

  subject { FactoryGirl.create(:deposit) }

end
