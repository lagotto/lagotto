class DataciteCrossref < Agent
  # include common methods for DataCite
  include Datacitable

  def q
    "relatedIdentifier:DOI\\:*"
  end

  def cron_line
    config.cron_line || "40 16 * * *"
  end

  def job_batch_size
    config.job_batch_size || 200
  end
end
