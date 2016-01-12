class Figshare < Agent
  def get_query_url(options={})
    work = Work.where(id: options.fetch(:work_id, nil)).first
    return {} unless work.present? && work.doi =~ /^10.1371/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, options={})
    return result if result[:error]

    work = Work.where(id: options.fetch(:work_id, nil)).first

    extra = result.fetch("items", [])

    views = get_sum(extra, 'stats', 'page_views')
    downloads = get_sum(extra, 'stats', 'downloads')
    likes = get_sum(extra, 'stats', 'likes')
    total = views + downloads + likes

    extra = nil if extra.blank?

    { events: [{
        source_id: name,
        work_id: work.pid,
        pdf: downloads,
        html: views,
        likes: likes,
        total: total,
        extra: extra }] }
  end

  def config_fields
    [:url_private]
  end
end
