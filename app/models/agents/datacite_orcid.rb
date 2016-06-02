class DataciteOrcid < Agent
  # include common methods for DataCite
  include Datacitable

  def q
    "nameIdentifier:ORCID\\:*"
  end

  def cron_line
    config.cron_line || "40 18 * * *"
  end
end
