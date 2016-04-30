# NSSM Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/nssm.svg?style=flat-square)][cookbook]
[![Build Status](http://img.shields.io/travis/dhoer/chef-nssm.svg?style=flat-square)][travis]

[cookbook]: https://supermarket.chef.io/cookbooks/nssm
[travis]: https://travis-ci.org/dhoer/chef-nssm

This cookbook installs the Non-Sucking Service Manager (http://nssm.cc), and exposes resources to `install`
and `remove` Windows services.

## Requirements

- Chef 11 or higher

### Platform

- Windows

### Cookbooks

- windows

## Usage

Add `recipe[nssm]` to run list.

### Quick Start

To install a Windows service:

```ruby
nssm 'service name' do
  program 'C:\Windows\System32\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  action :install
end
```

To remove a Windows service:

```ruby
nssm 'service name' do
  action :remove
end
```

### Using Parameters

A parameter is a hash key representing the same name as the registry entry which controls the associated functionality.
So, for example, the following sets the Startup directory, I/O redirection, and File rotation for a service:

```ruby
nssm 'service name' do
  program 'C:\Windows\System32\java.exe'
  args '-jar C:/path/to/my-executable.jar'
  params(
    AppDirectory: 'C:/path/to',
    AppStdout: 'C:/path/to/log/service.log',
    AppStderr: 'C:/path/to/log/error.log',
    AppRotateFiles: 1
  )
  action :install
end
```

### Arguments with Spaces

Having spaces in `servicename`, `program` and `params` attributes is not a problem, but spaces in an argument is a
different matter.

When dealing with an argument containing spaces, surround it
with [3 double quotes](http://stackoverflow.com/a/15262019):

```ruby
nssm 'service name' do
  program 'C:\Program Files\Java\jdk1.7.0_67\bin\java.exe'
  args '-jar """C:/path/with spaces to/my-executable.jar"""'
  action :install
end
```
    
When dealing with arguments requiring
[interpolation](http://en.wikibooks.org/wiki/Ruby_Programming/Syntax/Literals#Interpolation) and it contains one or
more arguments with spaces, then encapsulate the `args` string using `%()` notation and use `"""` around arguments
with spaces:

```ruby
my_path_with_spaces = 'C:/path/with spaces to/my-executable.jar'
nssm 'service name' do
  program 'C:\Program Files\Java\jdk1.7.0_67\bin\java.exe'
  args %(-jar """#{my_path_with_spaces}""")
  action :install
end
```

### Attributes

- `node['nssm']['src']` - This can either be a URI or a local path to nssm zip.
- `node['nssm']['sha256']` - SHA-256 checksum of the file. Chef will not download it if the local file matches the
checksum.

### Resource/Provider

#### Actions

- `install` - Install a Windows service.
- `remove` - Remove Windows service.

#### Attribute Parameters

- `servicename` - Name attribute. The name of the Windows service.
- `program` - The program to be run as a service.
- `args` - String of arguments for the program. Optional
- `params` - Hash of key value pairs where key represents associated registry entry. Optional
- `start` - Start service after installing. Default` -  true

## ChefSpec Matchers

The NSSM cookbook includes custom [ChefSpec](https://github.com/sethvargo/chefspec) matchers you can use to test your
own cookbooks that consume Windows cookbook LWRPs.

Example Matcher Usage

```ruby
expect(chef_run).to install_nssm('service name').with(
  :program 'C:\Windows\System32\java.exe'
  :args '-jar C:/path/to/my-executable.jar'    
)
```
      
NSSM Cookbook Matchers

- install_nssm(servicename)
- remove_nssm(servicename)

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/chef-nssm).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-nssm/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-nssm/blob/master/CONTRIBUTING.md).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-nssm/blob/master/LICENSE.md) file for details.
