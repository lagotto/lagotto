require 'spec_helper'

describe 'dotenv' do

  describe command('printenv TEST_VARIABLE') do
    its(:stdout) { should eq "dotenv_test" }
  end
end
