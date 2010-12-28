require 'AbstractsMetadataService.rb'
require 'AbstractsMetadataServiceMappingRegistry.rb'
require 'soap/rpc/driver'

class AbstractsMetadataServicePortType_V7 < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://cdc315-services.elsevier.com:80/EWSXAbstractsMetadataWebSvc/XAbstractsMetadataServiceV7"

  Methods = [
    [ "",
      "getPublishers",
      [ ["in", "getPublishers", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getPublishers"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getPublishersResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getPublishersResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getSourceMetadata",
      [ ["in", "getSourceMetadata", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceMetadata"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getSourceMetadataResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceMetadataResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getDbMetadata",
      [ ["in", "getDbMetadata", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getDbMetadata"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getDbMetadataResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getDbMetadataResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getSourceInfo",
      [ ["in", "getSourceInfo", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceInfo"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getSourceInfoResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceInfoResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getLinkData",
      [ ["in", "getLinkData", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getLinkData"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getLinkDataResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getLinkDataResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getCitedByCount",
      [ ["in", "getCitedByCount", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getCitedByCount"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getCitedByCountResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getCitedByCountResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getTopics",
      [ ["in", "getTopics", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getTopics"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getTopicsResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getTopicsResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "isCacheCurrent",
      [ ["in", "isCacheCurrent", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "isCacheCurrent"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "isCacheCurrentResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "isCacheCurrentResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getEIDs",
      [ ["in", "getEIDs", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getEIDs"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getEIDsResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getEIDsResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIResp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ],
    [ "",
      "getIDs",
      [ ["in", "getIDs", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getIDs"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getIDsResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getIDsResponse"]],
        ["out", "EASIResp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal,
        :faults => {} }
    ],
    [ "",
      "getSourceYearInfo",
      [ ["in", "getSourceYearInfo", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceYearInfo"]],
        ["in", "EASIReq", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIReq"]],
        ["out", "getSourceYearInfoResponse", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "getSourceYearInfoResponse"]],
        ["out", "mimeAttachment", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/metadata/abstracts/types/v7", "mimeAttachment"]],
        ["out", "EASIRsp", ["::SOAP::SOAPElement", "http://webservices.elsevier.com/schemas/easi/headers/types/v1", "EASIResp"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => nil,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = AbstractsMetadataServiceMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = AbstractsMetadataServiceMappingRegistry::LiteralRegistry
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

