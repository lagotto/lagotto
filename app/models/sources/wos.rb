# encoding: UTF-8

class Wos < Source
  def get_query_url(work)
    return nil unless work.doi.present?

    url
  end

  def get_data(work, options={})
    query_url = get_query_url(work)
    if query_url.nil?
      result = {}
    else
      data = get_xml_request(work)
      result = get_result(query_url, options.merge(content_type: 'xml', data: data))
    end
    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    # Check whether WOS has returned an error status message
    error_status = check_error_status(result, work)
    return { error: error_status } if error_status

    values = Array(result.deep_fetch('response', 'fn', 'map', 'map', 'map', 'val') { nil })
    event_count = values[0].to_i
    # fix for parsing error
    event_count = 0 if event_count > 100000
    events_url = values[2]

    { events: {},
      events_by_day: [],
      events_by_month: [],
      events_url: events_url,
      event_count: event_count,
      event_metrics: get_event_metrics(citations: event_count) }
  end

  def check_error_status(result, work)
    status = result.deep_fetch('response', 'fn', 'rc') { 'OK' }

    if status.casecmp('OK') == 0
      return false
    else
      if status == 'Server.authentication'
        class_name = 'Net::HTTPUnauthorized'
        status_code = 401
      else
        class_name = 'Net::HTTPNotFound'
        status_code = 404
      end
      error = result.deep_fetch('response', 'fn', 'error') { 'an error occured' }
      message = "Web of Science error #{status}: '#{error}' for work #{work.doi}"
      Alert.create(exception: '',
                   message: message,
                   class_name: class_name,
                   status: status_code,
                   source_id: id)
      return message
    end
  end

  def get_xml_request(work)
    xml = ::Builder::XmlMarkup.new(indent: 2)
    xml.instruct!
    xml.request(xmlns: 'http://www.isinet.com/xrpc42',
                src: "app.id=Lagotto,env.id=#{Rails.env},partner.email=#{ENV['ADMIN_EMAIL']}") do
      xml.fn(name: "LinksAMR.retrieve") do
        xml.list do
          xml.map
          xml.map do
            xml.list(name: 'WOS') do
              xml.val 'timesCited'
              xml.val 'ut'
              xml.val 'citingArticlesURL'
            end
          end
          xml.map do
            xml.map(name: 'cite_id') do
              xml.val work.doi, name: 'doi'
            end
          end
        end
      end
    end
  end

  def config_fields
    [:url]
  end
end
