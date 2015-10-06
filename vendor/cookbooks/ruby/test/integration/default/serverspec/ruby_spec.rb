require 'spec_helper'

describe 'ruby' do

  describe package('ruby2.2') do
    it { should be_installed }
  end

  describe package('ruby2.2-dev') do
    it { should be_installed }
  end

  describe command('ruby -v') do
    its(:stdout) { should match /ruby 2.2/ }
  end

  describe command('bundle -v') do
    its(:exit_status) { should eq 0 }
  end
end
