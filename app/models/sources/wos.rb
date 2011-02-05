# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2011 by Public Library of Science, a non-profit corporation
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

class Wos < Source
  include SourceHelper

  def uses_url; true; end

  def perform_query(article, options={})
    raise(ArgumentError, "Web of Science configuration requires url") \
      if url.blank?
    
    doc = XML::Document.new()
    doc.root = XML::Node.new('request')    
    doc.root['xmlns'] = "http://www.isinet.com/xrpc41"
    doc.root['src'] = "app.id=#{APP_CONFIG['useragent']},env.id=#{RAILS_ENV},partner.email=#{APP_CONFIG['notification_email']}"
    
    doc.root << fn = XML::Node.new('fn')
    fn['name'] = "LinksAMR.retrieve"
    
    fn << list = XML::Node.new('list')
    
    list << map1 = XML::Node.new('map')
    
    list << map2 = XML::Node.new('map')
    
    map2 << list2 = XML::Node.new('list')
    list2['name'] = "WOS"
    
    list2 << val = XML::Node.new('val')
    val << 'timesCited'
    list2 << val = XML::Node.new('val')
    val << 'ut'
    list2 << val = XML::Node.new('val')
    val << 'citingArticlesURL'
    
    list << map3 = XML::Node.new('map')
    map3 << map = XML::Node.new('map')
    map['name'] = "cite_id"
    
    map << val = XML::Node.new('val')
    val['name'] = "doi"
    val << article.doi

    url = "https://ws.isiknowledge.com/cps/xrpc"
    options[:postdata] = doc.to_s
    options[:extraheaders] = {'Content-Type' => 'text/xml'}

    citeCount = 0
    get_xml(url, options) do |document|
      # there should be only one node found
      status = ""
      nodes = document.find('//xrpc:fn', 'xrpc:http://www.isinet.com/xrpc41')
      nodes.each do | node |
        status = node['rc']

        if status.casecmp('OK') != 0
          Rails.logger.error "Error from Web of Science for article #{article.doi} Error Msg: #{node['rc']} #{node.content} #{node.to_s}"
          return 0;
        end
      end

      # there should be only one node found
      # Thomson Reuters unique identifier for the article
      nodes = document.find('//xrpc:map[@name=\'WOS\']/xrpc:val[@name=\'ut\']', 'xrpc:http://www.isinet.com/xrpc41')
      nodes.each do | node |
        options[:retrieval].local_id = node.content
      end

      # there should be only one node found
      # get the times cited information
      nodes = document.find('//xrpc:map[@name=\'WOS\']/xrpc:val[@name=\'timesCited\']', 'xrpc:http://www.isinet.com/xrpc41')
      nodes.each do | node |
        citeCount = node.content
      end
    end
    
    return citeCount.to_i
  end  

  def public_url(retrieval)

    # rearrange the url we get from web of science so that KeyUT parameter is at the end,
    # then we can store the url (from web of science) without the KeyUT parameter populated in the url column
    # and easily append the ut value (Thomson Reuters unique identifier for the article) at the end of the url
        
    "#{url}#{retrieval.local_id}"    
  end

end
