#
# Cookbook Name:: libarchive
# Attribute:: default
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#
if platform_family?('debian')
  default['libarchive']['package_name'] = 'libarchive-dev'
elsif platform_family?('rhel')
  default['libarchive']['package_name'] = 'libarchive-devel'
else
  default['libarchive']['package_name'] = 'libarchive'
end
