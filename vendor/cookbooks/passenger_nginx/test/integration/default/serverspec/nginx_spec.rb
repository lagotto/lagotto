require 'spec_helper'

describe 'nginx' do

  describe package('nginx-full') do
    it { should be_installed }
  end

  describe package('passenger') do
    it { should be_installed }
  end

  describe file('/etc/nginx/nginx.conf') do
    it { should be_file }
  end

  describe service('nginx') do
    it { should be_running }
  end
end
