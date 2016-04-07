require 'rails_helper'

describe Result, type: :model, vcr: true do
  before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2015, 4, 8)) }

  it { is_expected.to belong_to(:work) }
  it { is_expected.to belong_to(:source) }

end
