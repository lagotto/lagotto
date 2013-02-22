require 'test/unit'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'


module SOAP
module Fault


class TestFault < Test::Unit::TestCase

  def setup
    @client = SOAP::RPC::Driver.new(nil, 'urn:fault')
    @client.wiredump_dev = STDERR if $DEBUG
    @client.add_method("hello", "msg")
  end

  def teardown
    @client.reset_stream if @client
  end

  def test_fault
    @client.mapping_registry = SOAP::Mapping::EncodedRegistry.new
    @client.test_loopback_response << <<__XML__
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <soap:Fault>
      <faultcode>soap:Server</faultcode>
      <faultstring>DN cannot be empty</faultstring>
      <detail />
    </soap:Fault>
  </soap:Body>
</soap:Envelope>
__XML__
    begin
      @client.hello("world")
      assert(false)
    rescue ::SOAP::FaultError => e
      assert_equal("DN cannot be empty", e.message)
    end
  end
end


end
end
