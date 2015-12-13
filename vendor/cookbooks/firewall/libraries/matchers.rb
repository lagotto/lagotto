if defined?(ChefSpec)
  ChefSpec.define_matcher(:firewall)
  ChefSpec.define_matcher(:firewall_rule)

  # actions(:install, :restart, :disable, :flush, :save)

  def install_firewall(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall, :install, resource)
  end

  def restart_firewall(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall, :restart, resource)
  end

  def disable_firewall(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall, :disable, resource)
  end

  def flush_firewall(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall, :flush, resource)
  end

  def save_firewall(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall, :save, resource)
  end

  def create_firewall_rule(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:firewall_rule, :create, resource)
  end
end
