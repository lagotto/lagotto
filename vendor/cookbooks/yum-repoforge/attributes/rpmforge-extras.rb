default['yum']['rpmforge-extras']['repositoryid'] = 'rpmforge-extras'
default['yum']['rpmforge-extras']['description'] = 'RHEL $releasever - RPMforge.net - extras'
case platform_version.to_i
when 5
  default['yum']['rpmforge-extras']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el5/mirrors-rpmforge-extras'
when 6, 2013, 2014, 2015
  default['yum']['rpmforge-extras']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-extras'
when 7
  default['yum']['rpmforge-extras']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el7/mirrors-rpmforge-extras'
end
default['yum']['rpmforge-extras']['enabled'] = true
default['yum']['rpmforge-extras']['managed'] = true
default['yum']['rpmforge-extras']['gpgcheck'] = true
default['yum']['rpmforge-extras']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
