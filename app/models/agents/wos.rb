class Wos < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi.present?

    url_private
  end

  def get_data(options={})
    query_url = get_query_url(options)
    return query_url if query_url.is_a?(Hash)

    work = Work.where(id: options.fetch(:work_id, nil)).first

    data = get_xml_request(work)
    result = get_result(query_url, options.merge(content_type: 'xml', data: data))

    result.extend Hashie::Extensions::DeepFetch
  end

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    # Check whether WOS has returned an error status message
    error_status = check_error_status(result, work)
    return { error: error_status } if error_status

    values = Array(result.deep_fetch('response', 'fn', 'map', 'map', 'map', 'val') { nil })

    # workaround since we lost the xml attributes when converting to JSON
    if values.length == 3
      total = values[0].to_i
      wos = values[1]
      provenance_url = values[2]

      # store Web of Science ID if we haven't done this already
      work.update_attributes(wos: wos) if wos.present? && work.wos.blank?
    else
      total = 0
      provenance_url = nil
    end

    relations = []
    if total > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => "www.webofknowledge.com",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "cites",
                                 "total" => total,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id },
                     subj: { "pid" => "https://www.webofknowledge.com",
                             "URL" => "https://www.webofknowledge.com",
                             "title" => "Web of Science",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    relations
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
