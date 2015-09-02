default['yum']['rpmforge-testing']['repositoryid'] = 'rpmforge-testing'
default['yum']['rpmforge-testing']['description'] = 'RHEL $releasever - RPMforge.net - testing'
case platform_version.to_i
when 5
  default['yum']['rpmforge-testing']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el5/mirrors-rpmforge-testing'
when 6, 2013, 2014, 2015
  default['yum']['rpmforge-testing']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-testing'
when 7
  default['yum']['rpmforge-testing']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el7/mirrors-rpmforge-testing'
end
default['yum']['rpmforge-testing']['enabled'] = false
default['yum']['rpmforge-testing']['managed'] = false
default['yum']['rpmforge-testing']['gpgcheck'] = true
default['yum']['rpmforge-testing']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
