if defined?(ChefSpec)
  def create_libartifact_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:libartifact_file, :create, resource_name)
  end

  def delete_libartifact_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:libartifact_file, :delete, resource_name)
  end
end
