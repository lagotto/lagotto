class ZenodoDataExport < ::DataExport
  class MissingZenodoApiKey < Error ; end

  module ZenodoClientFactory
    API_KEY_ENV_VARIABLE_NAME = "ZENODO_KEY"
    URL_ENV_VARIABLE_NAME = "ZENODO_URL"

    def self.build(options={})
      api_key = options[:api_key] || ENV[API_KEY_ENV_VARIABLE_NAME]
      Zenodo::Client.new(api_key).tap do |client|
        client.url = options[:zenodo_url] || ENV[URL_ENV_VARIABLE_NAME]
      end
    end
  end

  def export!(options={})
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
    {
      'metadata' => {
        'title' => '(TEST) Monthly Stats Report',
        'upload_type' => 'dataset',
        'description' => '(TEST) Monthly Stats Report',
        'creators' =>[{'name' => 'Zach Dennis'}]
      }
    }
  end

  private

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
    zenodo_client.url = url if url

    deposition = zenodo_client.create_deposition(deposition: to_zenodo_deposition_attributes)

    files.each do |file|
      zenodo_client.create_deposition_file(id:deposition['id'], file_or_io:file)
    end

    zenodo_client.publish_deposition(id:deposition['id'])

    deposition = zenodo_client.get_deposition(id: deposition['id'])

    update_attributes!(
      url: deposition["record_url"],
      data: deposition.to_h
    )
  end

end
