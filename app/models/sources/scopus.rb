# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Configuration Instructions
#
# Change the PartnerId constant below to the one provided by Scopus.
#

require 'digest/md5'
require 'soap/wsdlDriver'
require 'soap/rpc/element'
require 'soap/header/simplehandler'
require 'AbstractsMetadataServiceDriver'
require 'rexml/element'

def fix_scopus_wsdl
  # The generated WSDL code has problems: fix them.
  # - it's set up to discard results, instead of returning them
  # - it wants an EASIReq object as a parameter, instead of putting it
  #   in the SOAP header as required by the service (we'll insert it in
  #   the header manually below).
  methods = AbstractsMetadataServicePortType_V10::Methods
  if methods[0][3][:response_use] != :literal
    methods.each do |method|
      method[3][:response_use] = :literal
      method[2].delete_if {|arg| arg[0..1] == [:in, "EASIReq"] }
    end
  end
end

class Scopus < Source

  validates_each :username, :salt, :partner_id do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})
    raise(ArgumentError, "#{display_name} configuration requires username, live_mode setting, salt and partner_id") \
      if config.username.blank? or config.live_mode.nil? or config.salt.blank? or config.partner_id.blank?

    # Guarantee Kosher for Great Justice
    fix_scopus_wsdl

    url = Scopus::query_url(config.live_mode)

    driver = get_soap_driver(config.username, url)

    result = driver.getCitedByCount(build_payload(article.doi))
    return unless result.status.statusCode == "OK"

    countList = result.getCitedByCountRspPayload.citedByCountList
    return if countList.nil? # we get no entry if this DOI wasn't found.
    countList[0].linkData[0].citedByCount.to_i

    event_url = get_event_url(article.doi)

    {:events => countList[0].linkData[0].citedByCount,
     :events_url => event_url,
     :event_count => countList[0].linkData[0].citedByCount}
  end

  def get_event_url(doi)
    #TODO this link doesn't seem to work anymore!
    query_string = "doi=" + CGI.escape(doi) \
      + "&rel=R3.0.0&partnerID=#{config.partner_id}"

    digest = Digest::MD5.hexdigest(query_string + config.salt)

    "http://www.scopus.com/scopus/inward/citedby.url?" \
      + query_string + "&md5=" + digest
  end

  def self.query_url(live_mode)
    "http://#{"cdc310-" unless live_mode}services.elsevier.com/EWSXAbstractsMetadataWebSvc/services/XAbstractsMetadataServiceV10"
  end

  def self.wsdl_url(live_mode)
    query_url(live_mode) + "/META-INF/absmet_service_v10.wsdl"
  end

  def get_config_fields
    [{:field_name => "username", :field_type => "text_field"},
    {:field_name => "live_mode", :field_type => "check_box"},
    {:field_name => "salt", :field_type => "password_field"},
    {:field_name => "partner_id", :field_type => "text_field"}]
  end

  def username
    config.username
  end
  def username=(value)
    config.username = value
  end

  def live_mode
    config.live_mode
  end
  def live_mode=(value)
    if value == "1"
      config.live_mode = true
    elsif value == "0"
      config.live_mode = false
    end
  end

  def salt
    config.salt
  end
  def salt=(value)
    config.salt = value
  end

  def partner_id
    config.partner_id
  end
  def partner_id=(value)
    config.partner_id = value
  end

  protected
  def get_soap_driver(username, url)
    driver = AbstractsMetadataServicePortType_V10.new(url)
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
      "ConsumerClient" => "Article_Level_Metrics",
      "LogLevel" => "Default"
    }
  end
end
