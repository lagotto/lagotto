class Wos < Agent
  def get_query_url(work)
    return {} unless work.doi.present?

    url_private
  end

  def get_data(work, options={})
    query_url = get_query_url(work)
    return query_url if query_url.is_a?(Hash)

    data = get_xml_request(work)
    result = get_result(query_url, options.merge(content_type: 'xml', data: data))

    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    # Check whether WOS has returned an error status message
    error_status = check_error_status(result, work)
    return { error: error_status } if error_status

    values = Array(result.deep_fetch('response', 'fn', 'map', 'map', 'map', 'val') { nil })

    # workaround since we lost the xml attributes when converting to JSON
    if values.length == 3
      total = values[0].to_i
      wos = values[1]
      events_url = values[2]

      # store Web of Science ID if we haven't done this already
      work.update_attributes(:wos => wos) if wos.present? && work.wos.blank?
    else
      total = 0
      events_url = nil
    end

    { events: [{
        source_id: name,
        work_id: work.pid,
        total: total,
        events_url: events_url }] }
  end

  def check_error_status(result, work)
    status = result.deep_fetch('response', 'fn', 'rc') { 'OK' }

    return false if status.casecmp('OK') == 0

    if status == 'Server.authentication'
      class_name = 'Net::HTTPUnauthorized'
      status_code = 401
    else
      class_name = 'Net::HTTPNotFound'
      status_code = 404
    end
    error = result.deep_fetch('response', 'fn', 'error') { 'an error occured' }
    message = "Web of Science error #{status}: '#{error}' for work #{work.doi}"
    Notification.where(message: message).where(unresolved: true).first_or_create(
      exception: "",
      class_name: class_name,
      status: status_code,
      source_id: id)
    message
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
    [:url_private]
  end
end
