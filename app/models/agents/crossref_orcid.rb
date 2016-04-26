class CrossrefOrcid < Agent
  # include common methods for Crossref
  include Crossrefable

  def q
    "has-orcid:true,"
  end

  def cron_line
    config.cron_line || "40 20 * * *"
  end
end
