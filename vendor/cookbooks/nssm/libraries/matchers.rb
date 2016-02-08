if defined?(ChefSpec)
  def install_nssm(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :install, servicename)
  end

  def remove_nssm(servicename)
    ChefSpec::Matchers::ResourceMatcher.new(:nssm, :remove, servicename)
  end
end
