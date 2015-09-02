require 'serverspec'

set :backend, :ssh

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end
