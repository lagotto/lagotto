require 'spec_helper'

describe 'ruby' do
  describe package('ruby2.1') do
    it { should be_installed }
  end

  describe package('ruby2.1-dev') do
    it { should be_installed }
  end

  describe command('ruby -v') do
    it { should return_stdout /ruby 2.1/ }
  end

  describe command('bundle -v') do
    it { should return_exit_status 0 }
  end
end
