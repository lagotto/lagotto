#
# Cookbook Name:: libarchive
# Library:: matchers
#
# Author:: John Bellone (<jbellone@bloomberg.net>)
#

if defined?(ChefSpec)
  def extract_libarchive_file(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:libarchive_file, :extract, resource_name)
  end
end
