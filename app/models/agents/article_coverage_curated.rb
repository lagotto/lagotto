class ArticleCoverageCurated < Agent
  # include common methods for Article Coverage
  include Coverable

  def get_relations_with_related_works(result, work)
    Array(result.fetch('referrals', nil)).map do |item|
      type = item.fetch("type", nil)
      type = MEDIACURATION_TYPE_TRANSLATIONS.fetch(type, nil) if type
      item_url = item.fetch('referral', nil)

      { relation: { "subj_id" => item_url,
                    "obj_id" => work.pid,
                    "relation_type_id" => "discusses",
                    "source_id" => source_id },
        subj: { "pid" => item_url,
                "author" => nil,
                "title" => item.fetch("title", ""),
                "container-title" => item.fetch("publication", ""),
                "issued" => get_iso8601_from_time(item.fetch('published_on', nil)),
                "URL" => item_url,
                "type" => type,
                "tracked" => false } }
    end
  end
end
