class Figshare < Source
  def get_query_url(work)
    return {} unless work.doi =~ /^10.1371/

    url_private % { :doi => work.doi }
  end

  def parse_data(result, work, options={})
    return result if result[:error]

    extra = result.fetch("items", [])

    views = get_sum(extra, 'stats', 'page_views')
    downloads = get_sum(extra, 'stats', 'downloads')
    likes = get_sum(extra, 'stats', 'likes')
    total = views + downloads + likes

    extra = nil if extra.blank?

    { events: {
        source: name,
        work: work.pid,
        pdf: downloads,
        html: views,
        likes: likes,
        total: total,
        extra: extra } }
  end

  def config_fields
    [:url_private]
  end
end
