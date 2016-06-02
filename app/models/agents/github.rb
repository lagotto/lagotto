class Github < Agent
  def request_options
    { bearer: personal_access_token, agent_id: id }
  end

  def get_query_url(options={})
    return {} unless options[:owner].present? && options[:repo].present?

    url % { owner: options[:owner], repo: options[:repo] }
  end

  def get_provenance_url(options={})
    return nil unless options[:owner].present? && options[:repo].present?

    provenance_url % { owner: options[:owner], repo: options[:repo] }
  end

  def get_total(options={})
    Work.tracked.where(registration_agency: 'github').count
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    works = Work.tracked.where(registration_agency: 'github').pluck(:id)
    total = works.size

    works.each_slice(job_batch_size) do |ids|
      AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options.merge(ids: ids))
    end

    schedule_next_run if total > 0

    # return number of works queued
    total
  end

  def get_data(options={})
    work = Work.where(id: options[:work_id]).first
    return {} unless work.present? && github_repo_from_url(work.canonical_url).present?

    query_url = get_query_url(get_owner_and_repo(work))
    return {} if query_url.is_a?(Hash)

    get_result(query_url, options.merge(request_options))
  end

  def get_owner_and_repo(work)
    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    return {} unless work.canonical_url.present? && /^https:\/\/github\.com\/(.+)\/(.+)/.match(work.canonical_url)

    full_name = URI.parse(work.canonical_url).path[1..-1]
    owner, repo = full_name.split('/')
    { owner: owner, repo: repo }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options[:work_id]).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    relations = []
    provenance_url = get_provenance_url(get_owner_and_repo(work)) if work.canonical_url.present?
    now = Date.new(current_year, current_month, 1)
    subj_date = get_date_from_parts(current_year, current_month, 1)
    subj_id = "https://github.com/#{current_year}/#{current_month}"
    subj = { "pid" => subj_id,
             "URL" => "https://github.com",
             "title" => "Github activity for #{now.strftime("%B %Y")}",
             "type" => "webpage",
             "issued" => subj_date }

    stargazers_count = result.fetch("stargazers_count", 0)
    if stargazers_count > 0
      relations << { prefix: work.prefix,
                     occurred_at: subj_date,
                     relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "bookmarks",
                                 "total" => stargazers_count,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id,
                                 "registration_agency_id" => "github" },
                     subj: subj }
    end

    forks_count = result.fetch("forks_count", 0)
    if forks_count > 0
      relations << { prefix: work.prefix,
                     occurred_at: subj_date,
                     relation: { "subj_id" => subj_id,
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "is_derived_from",
                                 "total" => forks_count,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id,
                                 "registration_agency_id" => "github" },
                     subj: subj }
    end

    relations
  end

  def config_fields
    [:url, :provenance_url, :personal_access_token]
  end

  def url
    "https://api.github.com/repos/%{owner}/%{repo}"
  end

  def provenance_url
    "https://github.com/%{owner}/%{repo}"
  end

  # More info at https://github.com/blog/1509-personal-api-tokens
  def personal_access_token
    config.personal_access_token
  end

  def personal_access_token=(value)
    config.personal_access_token = value
  end

  def rate_limiting
    config.rate_limiting || 4500
  end

  def cron_line
    config.cron_line || "40 20 * * *"
  end
end
