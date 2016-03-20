class Figshare < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, options={})
    return [result] if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    extra = result.fetch("items", [])

    views = get_sum(extra, 'stats', 'page_views')
    downloads = get_sum(extra, 'stats', 'downloads')
    likes = get_sum(extra, 'stats', 'likes')

    subj_id = "https://figshare.com"
    subj = { "pid" => subj_id,
             "URL" => subj_id,
             "title" => "Figshare",
             "type" => "webpage",
             "issued" => "2012-05-15T16:40:23Z" }

    relations = []
    if downloads > 0
      relations << { relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "downloads",
                                 "total" => downloads,
                                 "source_id" => source_id },
                     subj: subj }
    end

    if views > 0
      relations << { relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "views",
                                 "total" => views,
                                 "source_id" => source_id },
                     subj: subj }
    end

    if likes > 0
      relations << { relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "likes",
                                 "total" => likes,
                                 "source_id" => source_id },
                     subj: subj }
    end

    relations
  end

  def config_fields
    [:url_private]
  end
end
