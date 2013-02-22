require 'echo_version.rb'
require 'echo_versionMappingRegistry.rb'
require 'soap/rpc/driver'

classEcho_version_port_type<::SOAP::RPC::Driver  DefaultEndpointUrl="http://localhost:10080"NsSimpletypeRpc="urn:example.com:simpletype-rpc"
  Methods=[[XSD::QName.new(NsSimpletypeRpc,"echo_version"),"urn:example.com:simpletype-rpc","echo_version",[[:in,"version",[nil,"urn:example.com:simpletype-rpc-type","version"]],[:retval,"version_struct",["Version_struct","urn:example.com:simpletype-rpc-type","version_struct"]]],{:request_style=>:rpc,:request_use=>:encoded,:response_style=>:rpc,:response_use=>:encoded,:faults=>{}}],[XSD::QName.new(NsSimpletypeRpc,"echo_version_r"),"urn:example.com:simpletype-rpc","echo_version_r",[[:in,"version_struct",["Version_struct","urn:example.com:simpletype-rpc-type","version_struct"]],[:retval,"version",[nil,"urn:example.com:simpletype-rpc-type","version"]]],{:request_style=>:rpc,:request_use=>:encoded,:response_style=>:rpc,:response_use=>:encoded,:faults=>{}}]]
  definitialize(endpoint_url=nil)endpoint_url||=DefaultEndpointUrlsuper(endpoint_url,nil)self.mapping_registry=Echo_versionMappingRegistry::EncodedRegistryself.literal_mapping_registry=Echo_versionMappingRegistry::LiteralRegistryinit_methodsend
private

  definit_methodsMethods.eachdo|definitions|opt=definitions.lastifopt[:request_style]==:documentadd_document_operation(*definitions)elseadd_rpc_operation(*definitions)qname=definitions[0]name=definitions[2]ifqname.name!=nameandqname.name.capitalize==name.capitalize::SOAP::Mapping.define_singleton_method(self,qname.name)do|*arg|__send__(name,*arg)endendendendendend
