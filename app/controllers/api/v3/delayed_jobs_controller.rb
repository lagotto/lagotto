class Api::V3::DelayedJobsController < Api::V3::BaseController

  load_and_authorize_resource

  def index
    @sources = Source.active.map { |source| { id: source.id,
                                              name: source.display_name,
                                              state: source.human_state_name,
                                              url: admin_source_path(source),
                                              group: source.group_id,
                                              queueing_count: source.get_queueing_job_count,
                                              pending_count: source.delayed_jobs.count - source.delayed_jobs.count(:locked_at),
                                              working_count: source.delayed_jobs.count(:locked_at),
                                              stale_count: source.retrieval_statuses.stale.count }}

    @cache_key = ApiCacheKey.find_by_name("delayed_jobs")
  end

end