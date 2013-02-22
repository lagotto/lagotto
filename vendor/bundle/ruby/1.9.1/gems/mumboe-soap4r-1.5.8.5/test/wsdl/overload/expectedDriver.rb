require 'default.rb'
require 'defaultMappingRegistry.rb'
require 'soap/rpc/driver'

class OverloadServicePortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost/"
  NsOverload = "urn:overload"

  Methods = [
    [ XSD::QName.new(NsOverload, "methodAlpha"),
      "methodAlpha1",
      "methodAlpha",
      [ [:in, "in0", ["::SOAP::SOAPString"]],
        [:in, "in1", ["::SOAP::SOAPString"]],
        [:in, "in2", ["::SOAP::SOAPString"]],
        [:retval, "methodAlphaReturn", ["::SOAP::SOAPLong"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new(NsOverload, "methodAlpha"),
      "methodAlpha2",
      "methodAlpha_2",
      [ [:in, "in0", ["::SOAP::SOAPString"]],
        [:in, "in1", ["::SOAP::SOAPString"]],
        [:retval, "methodAlphaReturn", ["::SOAP::SOAPLong"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        add_document_operation(*definitions)
      else
        add_rpc_operation(*definitions)
        qname = definitions[0]
        name = definitions[2]
        if qname.name != name and qname.name.capitalize == name.capitalize
          ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
            __send__(name, *arg)
          end
        end
      end
    end
  end
end

