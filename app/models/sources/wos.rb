
class Wos < Source

  validates_each :url do |record, attr, value|
    record.errors.add(attr, "can't be blank") if value.blank?
  end

  def get_data(article, options={})

    doc = XML::Document.new()
    doc.root = XML::Node.new('request')
    doc.root['xmlns'] = "http://www.isinet.com/xrpc41"
    doc.root['src'] = "app.id=#{APP_CONFIG['useragent']},env.id=#{Rails.env},partner.email=#{APP_CONFIG['notification_email']}"

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

    query_url = get_query_url(article)

    get_xml(query_url, options.merge(:postdata => doc.to_s, :extraheaders => {'Content-Type' => 'text/xml'})) do |document|
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

      cite_count = 0
      # there should be only one node found
      # get the times cited information
      nodes = document.find('//xrpc:map[@name=\'WOS\']/xrpc:val[@name=\'timesCited\']', 'xrpc:http://www.isinet.com/xrpc41')
      nodes.each do | node |
        cite_count = node.content
      end

      url = nil
      # there should be only one node found
      # get the citing articles url information
      nodes = document.find('//xrpc:map[@name=\'WOS\']/xrpc:val[@name=\'citingArticlesURL\']', 'xrpc:http://www.isinet.com/xrpc41')
      nodes.each do | node |
        url = node.content
      end

      xml_string = document.to_s(:encoding => XML::Encoding::UTF_8)

      {:events => cite_count,
       :events_url => url,
       :event_count => cite_count,
       :attachment => {:filename => "events.xml", :content_type => "text\/xml", :data => xml_string }
      }

    end
  end

  def get_query_url(article)
    config.url
  end

  def get_config_fields
    [{:field_name => "url", :field_type => "text_area", :size => "90x2"}]
  end

  def url
    config.url
  end

  def url=(value)
    config.url = value
  end

end
