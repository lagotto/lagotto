class DataoneUsage < Agent
  # include common methods for DataONE
  include Dataoneable

  def get_query_url(work)
    return {} unless work.dataone.present?

    params = { q: "pid:#{work.dataone_escaped} AND isRepeatVisit:false AND inPartialRobotList:false",
               fq: "event:read",
               facet: "true",
               "facet.range" => "dateLogged",
               "facet.range.start" => "#{work.published_on}T00:00:00Z",
               "facet.range.end" => "#{Time.zone.now.to_date}T23:59:59Z",
               "facet.range.gap" => "+1MONTH",
               wt: "json" }
    url + params.to_query
  end
end
