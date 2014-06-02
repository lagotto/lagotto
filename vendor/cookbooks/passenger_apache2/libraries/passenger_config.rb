module Chef::Recipe::PassengerConfig

  # This function takes a version string and returns the name of the directory
  # containing the build artifacts for that version.
  #
  # Prior to version 3.9.1.beta, passenger put build artifacts into
  # a directory called 'ext'
  # From version 3.9.1.beta through version 4.0.5, the build artifacts
  # were put in 'libout'.
  # Since then, build artifacts are in 'buildout'
  #
  # All versions: http://rubygems.org/gems/passenger/versions
  def self.build_directory_for_version(version)
    required_version = Gem::Version.new(version)
    if Gem::Requirement.new('> 4.0.5').satisfied_by?(required_version)
      'buildout'
    elsif Gem::Requirement.new('>= 3.9.0').satisfied_by?(required_version)
      'libout'
    else
      'ext'
    end
  end
end
