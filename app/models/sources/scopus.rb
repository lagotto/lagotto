require 'soap/wsdlDriver'
require 'soap/rpc/element'
require 'soap/header/simplehandler'
$: << File.join(Rails.root, 'app', 'models', 'sources', 'scopus')
require 'AbstractsMetadataServiceDriver.rb'

def fix_scopus_wsdl
  # The generated WSDL code has problems: fix them.
  # - it's set up to discard results, instead of returning them
  # - it wants an EASIReq object as a parameter, instead of putting it
  #   in the SOAP header as required by the service (we'll insert it in
  #   the header manually below).
  methods = AbstractsMetadataServicePortType_V7::Methods
  if methods[0][3][:response_use] != :literal
    methods.each do |method| 
      method[3][:response_use] = :literal
      method[2].delete_if {|arg| arg[0..1] == ["in", "EASIReq"] }
    end
  end
end
fix_scopus_wsdl

class Scopus < Source
  def uses_url; true; end
  def uses_username; true; end

  def query(article)
    raise(ArgumentError, "Scopus configuration requires URL & username") \
      if url.blank? or username.blank?

    driver = get_soap_driver(username)
    result = driver.getCitedByCount(build_payload(article.doi))
    return -1 unless result.status.statusCode == "OK"

    #list = result.getCitedByCountRspPayload.citedByCountList
    #list.each {|r| puts "#{r.inputKey.doi} => #{r.linkData[0].citedByCount} citations"}

    countList = result.getCitedByCountRspPayload.citedByCountList
    return 0 if countList.nil? # we get no entry if this DOI wasn't found.
    countList[0].linkData[0].citedByCount.to_i
  end

protected
  
  def get_soap_driver(username)
    driver = AbstractsMetadataServicePortType_V7.new
    # driver.wiredump_dev = STDOUT
    driver.headerhandler << ScopusSoapHeader.new(username)
    driver
  end

  def build_payload(*doi_list)
    inputkeys = []
    doi_list.each_with_index do |doi, index| 
      inputkeys << InputKeyType.new(doi, nil, nil, nil, nil, nil, nil, nil, nil, nil, 
                                    nil, nil, nil, nil, nil, nil, index.to_s)
    end

    GetCitedByCountType.new(GetLinkDataReqPayloadType.new(nil, 
      AbsMetSourceType::All, ResponseStyleType::WellDefined, 
      DataResponseType.new("MESSAGE"), inputkeys))
  end
end

class ScopusSoapHeader < SOAP::Header::SimpleHandler
  def initialize(username)
    super(XSD::QName.new(AbstractsMetadataServiceMappingRegistry::NsV1, "EASIReq"))
    @username = username
  end

  def on_simple_outbound
    # Build a synthetic EASIReq header
    { "ReqId" => '1',
      "Ver" => '2',
      "Consumer" => @username,
      "ConsumerClient" => "PLoS_Article_Metrics",
      "LogLevel" => "Default"
    }
  end
end

