def service_user
  value_for_platform_family(
    %w(suse fedora rhel) => 'memcached',
    'debian' => 'memcache',
    'default' => 'nobody'
  )
end

def service_group
  value_for_platform_family(
    %w(suse fedora rhel) => 'memcached',
    'debian' => 'memcache',
    'default' => 'nogroup'
  )
end
