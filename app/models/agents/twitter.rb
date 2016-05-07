class Twitter < Agent
  def request_options
    { agent_id: id }
  end

  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371/

    url_private % { :doi => work.doi_escaped }
  end

  def get_relations_with_related_works(result, work)
    Array(result['rows']).map do |item|
      data = item['value']
      if data.key?("from_user")
        user = data["from_user"]
        user_name = data["from_user_name"]
        user_profile_image = data["profile_image_url"]
      else
        user = data["user"]["screen_name"]
        user_name = data["user"]["name"]
        user_profile_image = data["user"]["profile_image_url"]
      end

      url = "http://twitter.com/#{user}/status/#{data['id_str']}"

      { prefix: work.prefix,
        relation: { "subj_id" => url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "source_id" => source_id },
        subj: { "pid" => url,
                "author" => get_authors([user_name]),
                "title" => data.fetch('text', ''),
                "container-title" => 'Twitter',
                "issued" => get_iso8601_from_time(data['created_at']),
                "URL" => url,
                "type" => 'personal_communication',
                "tracked" => tracked,
                "registration_agency_id" => "twitter" }}
    end
  end

  def config_fields
    [:url_private]
  end

  def cron_line
    config.cron_line || "* 6,18 * * *"
  end

  def queue
    config.queue || "high"
  end
end
