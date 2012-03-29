require 'source_helper'
require 'cgi'

class Source < ActiveRecord::Base
  include SourceHelper

  serialize :config, OpenStruct

  def get_data(article, options={})
    raise NotImplementedError, 'Children classes should override get_data method'
  end

  def queue_all_articles
    # determine if the source is active
    if active && (disable_until.nil? || disable_until < Time.now.utc)

      # reset disable_until value
      unless self.disable_until.nil?
        self.disable_until = nil
        save
      end

      # grab all the articles
      retrieval_statuses = RetrievalStatus.joins(:article, :source).
          where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL',
                id, Time.zone.today).
          readonly(false)

      retrieval_statuses.find_each do | retrieval_status |

        retrieval_history = RetrievalHistory.new
        retrieval_history.article_id = retrieval_status.article_id
        retrieval_history.source_id = id
        retrieval_history.save

        Delayed::Job.enqueue SourceJob.new(retrieval_status.article_id, self, retrieval_status, retrieval_history), :queue => name
      end

    else
      Rails.logger.error "#{name} is either inactive or is disabled."
      raise "#{display_name} (#{name}) is either inactive or is disabled"
    end
  end

  def queue_articles

    # get the source specific configurations
    source_config = YAML.load_file("#{Rails.root}/config/source_configs.yml")[Rails.env]
    source_config = source_config[name]

    if !source_config.has_key?('batch_time_interval') || !source_config.has_key?('staleness')
      Rails.logger.error "#{display_name}: batch_time_interval is missing or staleness is missing"
      raise "#{display_name}: batch_time_interval is missing or staleness is missing"
      return
    end

    source_config['batch_time_interval'] = parse_time_config(source_config['batch_time_interval'])
    source_config['staleness'] = parse_time_config(source_config['staleness'])

    # determine if the source is active
    if active
      queue_job = true

      # determine if the source is disabled or not
      unless self.disable_until.nil?
        queue_job = false

        if self.disable_until < Time.now.utc
          self.disable_until = nil
          save
          queue_job = true
        elsif self.disable_until < (Time.now.utc + source_config['batch_time_interval'])
          # the source will become not disabled before the next round (of job queueing)
          # just sleep til the source will become not disabled and queue the jobs
          source_config['batch_time_interval'] = Time.now.utc - self.disable_until
        end
      end

      if queue_job
        queue_article_jobs(source_config)
      end
    end

    return source_config['batch_time_interval']
  end

  def queue_article_jobs(source_config)
    # find articles that need to be updated

    # not queued currently
    # stale from updated_at
    retrieval_statuses = RetrievalStatus.joins(:article, :source).
        where('sources.id = ?
               and articles.published_on < ?
               and queued_at is NULL
               and retrieved_at < TIMESTAMPADD(SECOND, - ?, UTC_TIMESTAMP())',
              id, Time.zone.today, source_config['staleness'].seconds.to_i).
        readonly(false)

    Rails.logger.debug "#{name} total article queued #{retrieval_statuses.length}"

    retrieval_statuses.each do | retrieval_status |

      retrieval_history = RetrievalHistory.new
      retrieval_history.article_id = retrieval_status.article_id
      retrieval_history.source_id = id
      retrieval_history.save

      Delayed::Job.enqueue SourceJob.new(retrieval_status.article_id, self, retrieval_status, retrieval_history), :queue => name
    end
  end

  private

  def parse_time_config(time_interval_config)
    unless time_interval_config.nil?
      index = time_interval_config.index('.')
      number = time_interval_config[0,index]
      method = time_interval_config[index + 1, time_interval_config.length]
      return number.to_i.send(method)
    end
  end

end
