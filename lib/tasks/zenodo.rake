namespace :zenodo do
  desc 'Checks to see everything is configured for Zenodo integration'
  task :requirements_check do
    if !ENV['ZENODO_KEY'] || !ENV['ZENODO_URL']
      raise <<-EOS.gsub(/^\s*/, '')
        Zenodo integration is not configured. To integrate with Zenodo
        please make sure you have set the ZENODO_KEY and ZENODO_URL
        environment variables.
      EOS
    end

    ENV['APPLICATION'] || raise("APPLICATION env variable must be set!")
    ENV['CREATOR'] || raise("CREATOR env variable must be set!")
    ENV['SITE_TITLE'] || raise("SITE_TITLE env variable must be set!")
    ENV['GITHUB_URL'] || raise("GITHUB_URL env variable must be set!")
  end
end
