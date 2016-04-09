class Bitbucket < Agent
  def get_query_url(options={})
    return {} unless options[:owner].present? && options[:repo].present?

    url % { owner: options[:owner], repo: options[:repo] }
  end

  def get_provenance_url(options={})
    return nil unless options[:owner].present? && options[:repo].present?

    provenance_url % { owner: options[:owner], repo: options[:repo] }
  end

  def get_total(options={})
    Work.tracked.where(registration_agency: 'bitbucket').count
  end

  def queue_jobs(options={})
    return 0 unless active?

    unless options[:all]
      return 0 unless stale?
    end

    works = Work.tracked.where(registration_agency: 'bitbucket').pluck(:id)
    total = works.size

    works.pluck_in_batches(:id, batch_size: job_batch_size) do |ids|
      AgentJob.set(queue: queue, wait_until: schedule_at).perform_later(self, options.merge(ids: ids))
    end

    schedule_next_run if total > 0

    # return number of works queued
    total
  end

  def get_data(options={})
    work = Work.where(id: options[:work_id]).first
    return {} unless work.present?

    query_url = get_query_url(get_owner_and_repo(work))
    return {} if query_url.is_a?(Hash)

    get_result(query_url, options)
  end

  def get_owner_and_repo(work)
    # code from https://github.com/octokit/octokit.rb/blob/master/lib/octokit/repository.rb
    return {} unless work.canonical_url.present? && /^https:\/\/bitbucket\.org\/(.+)\/(.+)/.match(work.canonical_url)

    full_name = URI.parse(work.canonical_url).path[1..-1]
    owner, repo = full_name.split('/')
    { owner: owner, repo: repo }
  end

  def parse_data(result, options={})
    return [result] if result[:error]
    work = Work.where(id: options[:work_id]).first
    return [{ error: "Resource not found.", status: 404 }] unless work.present?

    relations = []
    provenance_url = get_provenance_url(get_owner_and_repo(work))
    followers_count = result.fetch("followers_count", 0)
    if followers_count > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => "https://bitbucket.org",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "bookmarks",
                                 "total" => followers_count,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id },
                     subj: { "pid" => "https://bitbucket.org",
                             "URL" => "https://bitbucket.org",
                             "title" => "Bitbucket",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    forks_count = result.fetch("forks_count", 0)
    if forks_count > 0
      relations << { prefix: work.prefix,
                     relation: { "subj_id" => "https://bitbucket.org",
                                 "obj_id" => work.pid,
                                 "relation_type_id" => "is_derived_from",
                                 "total" => forks_count,
                                 "provenance_url" => provenance_url,
                                 "source_id" => source_id },
                     subj: { "pid" => "https://bitbucket.org",
                             "URL" => "https://bitbucket.org",
                             "title" => "Bitbucket",
                             "issued" => "2012-05-15T16:40:23Z" }}
    end

    relations
  end

  def config_fields
    [:url, :provenance_url]
  end

  def url
    "https://api.bitbucket.org/1.0/repositories/%{owner}/%{repo}"
  end

  def provenance_url
    "https://bitbucket.org/%{owner}/%{repo}"
  end

  def rate_limiting
    config.rate_limiting || 30000
  end
end
