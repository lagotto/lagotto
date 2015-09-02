remote_syslog2 cookbook
=======================
Installs and configures [remote_syslog2](https://github.com/papertrail/remote_syslog2)

Requirements
------------
### Platforms
- Ubuntu (tested using 14.04)

Attributes
----------
### remote_syslog2 runtime configuration
The main configuration of remote_syslog2 is done using a hash which mirrors the structure of the remote_syslog2 config yaml file...

```ruby
node['remote_syslog2']['config'] = {
  files: [],
  exclude_files: [],
  exclude_patterns: [],
  hostname: node['hostname'],
  destination: {
    host: 'logs.papertrailapp.com',
    port: 12345
  }
}
```

Since this is rendered directly to YAML, you can theoretically configure any value which is normally configurable. For more information please reference the [remote_syslog2 examples](https://github.com/papertrail/remote_syslog2/tree/master/examples)

**Note that for the sake of clarity this cookbook saves the config file to /etc/remote_syslog2.yml rather than /etc/log_files.yml by default**

Recipes
-------
### default
Include the default recipe in a run list to have remote_syslog2 installed and configured

### install
Installs remote_syslog2

### configure
Generates config file for remote_syslog2

### service
Installs remote_syslog2 as an init.d service and starts/enables it

Usage
-----
Generally all you have to do to use this cookbook is add the default recipe to your run_list and configure the `node['remote_syslog2']['config']` hash.

License and Authors
-------------------
Author:: Jeff Way (<jeff.way@me.com>)
