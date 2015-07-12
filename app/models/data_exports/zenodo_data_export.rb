class ZenodoDataExport < ::DataExport
  class MissingZenodoApiKey < Error ; end

  module ZenodoClientFactory
    API_KEY_ENV_VARIABLE_NAME = "ZENODO_KEY"
    URL_ENV_VARIABLE_NAME = "ZENODO_URL"

    def self.build(options={})
      api_key = options[:api_key] || ENV[API_KEY_ENV_VARIABLE_NAME]
      url = options[:zenodo_url] || ENV[URL_ENV_VARIABLE_NAME]
      Zenodo::Client.new(api_key, url)
    end
  end

  # Zenodo deposition attributes: https://zenodo.org/dev#restapi-rep-meta
  data_attribute :publication_date
  data_attribute :title
  data_attribute :description
  data_attribute :creators, default: []
  data_attribute :keywords, default: []
  data_attribute :remote_deposition

  # So we can tie our Zenodo export back to the code that generated it
  data_attribute :code_repository_url

  validates :publication_date, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :creators, presence: true
  validates :keywords, presence: true
  validates :code_repository_url, presence: true

  def finished?
    !!finished_exporting_at
  end

  def export!(options={})
    return if finished?
    zenodo_client_factory = options[:zenodo_client_factory] || ZenodoClientFactory
    zenodo_client = zenodo_client_factory.build(options.slice(:api_key, :zenodo_url))

    touch(:started_exporting_at)

    ensure_files_exists!

    result = perform_upload(zenodo_client)

    touch(:finished_exporting_at)
  rescue Exception => ex
    update_attributes started_exporting_at:nil, finished_exporting_at:nil
    raise ex
  end

  def to_zenodo_deposition_attributes
    {}.tap do |attrs|
      attrs["metadata"] = build_metdata_for_deposition_attributes
    end
  end

  private

  def build_metdata_for_deposition_attributes
    {
      "upload_type" => "dataset",
      "publication_date" => publication_date.to_s,
      "title" => title,
      "description" => description,
      "creators" => creators.map{ |name| {"name" => name } },
      "keywords" => keywords,
      "access_right" => "open",
      "license" => "cc-zero",
      "related_identifiers" => build_related_identifiers_for_deposition_metadata
    }
  end

  def build_related_identifiers_for_deposition_metadata
    related_identifiers = [
      { "relation" => "isSupplementTo", "identifier" => code_repository_url }
    ]

    if previous_version
      related_identifiers << { "relation" => "isNewVersionOf", "identifier" => previous_version.remote_deposition["doi"] }
    end

    related_identifiers
  end

  def ensure_files_exists!
    files.each do |file|
      unless File.exists?(file)
        raise FileNotFoundError, <<-ERROR.gsub(/^\s*/)
          File not found: #{file}
        ERROR
      end
    end
  end

  def perform_upload(zenodo_client)
    deposition = zenodo_client.create_deposition(deposition: to_zenodo_deposition_attributes)

    files.each do |file|
      zenodo_client.create_deposition_file(id:deposition['id'], file_or_io:file)
    end

    zenodo_client.publish_deposition(id:deposition['id'])

    deposition = zenodo_client.get_deposition(id: deposition['id'])

    self.url = deposition["record_url"]
    self.remote_deposition = deposition.to_h

    save!
  end

end
