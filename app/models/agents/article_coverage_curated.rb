class ArticleCoverageCurated < Agent
  # include common methods for Article Coverage
  include Coverable

  def get_relations_with_related_works(result, work)
    Array(result.fetch('referrals', nil)).map do |item|
      timestamp = get_iso8601_from_time(item.fetch('published_on', nil))

      type = item.fetch("type", nil)
      type = MEDIACURATION_TYPE_TRANSLATIONS.fetch(type, nil) if type
      item_url = item.fetch('referral', nil)

      { relation: { "subject_id" => item_url,
                    "object_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "source_id" => source_id,
                    "occurred_at" => timestamp,
                    # TODO JW comments not available in API response.
                    "total" => item.fetch("comments", 0) },
        subject: { "pid" => item_url,
                   "author" => nil,
                   "title" => item.fetch("title", ""),
                   "container-title" => item.fetch("publication", ""),
                   "issued" => get_date_parts(timestamp),
                   "timestamp" => timestamp,
                   "URL" => item_url,
                   "type" => type,
                   "tracked" => true } }
    end
  end

  # TODO dispose of this?
  # def get_extra(result)
  #   Array(result.fetch('referrals', nil)).map do |item|
  #     event_time = get_iso8601_from_time(item['published_on'])
  #     url = item['referral']
  #     type = item.fetch("type", nil)
  #     type = MEDIACURATION_TYPE_TRANSLATIONS.fetch(type, nil) if type

  #     { event: item,
  #       event_time: event_time,
  #       event_url: url,

  #       # the rest is CSL (citation style language)
  #       event_csl: {
  #         'author' => '',
  #         'title' => item.fetch('title') { '' },
  #         'container-title' => item.fetch('publication') { '' }, # TODO ??
  #         'issued' => get_date_parts(event_time),
  #         'url' => url,
  #         'type' => type }
  #       }
  #   end
  # end
end
