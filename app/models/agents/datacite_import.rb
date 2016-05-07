class DataciteImport < Agent
  # include common methods for DataCite
  include Datacitable

  def q
    "*:*"
  end
end
