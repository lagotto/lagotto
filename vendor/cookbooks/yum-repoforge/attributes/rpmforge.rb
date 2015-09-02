default['yum']['rpmforge']['repositoryid'] = 'rpmforge'
default['yum']['rpmforge']['description'] = 'RHEL $releasever - RPMforge.net - dag'
case platform_version.to_i
when 5
  default['yum']['rpmforge']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el5/mirrors-rpmforge'
when 6, 2013, 2014, 2015
  default['yum']['rpmforge']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge'
when 7
  default['yum']['rpmforge']['mirrorlist'] = 'http://mirrorlist.repoforge.org/el7/mirrors-rpmforge'
end
default['yum']['rpmforge']['enabled'] = true
default['yum']['rpmforge']['managed'] = true
default['yum']['rpmforge']['gpgcheck'] = true
default['yum']['rpmforge']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
