# libartifact-cookbook
[Library cookbook][1] which provides a resource for managing release
artifacts.

This cookbook takes an opinionated approach to managing release
artifacts on the system. It utilizes the [libarchive cookbook][2] to
extract remote files to a release directory. After this is done it
creates (or updates) a _current symlink_ so that scripts can always
reference the most recent version of the packaged software.

An example of the layout on the file system would go as follows:
```sh
/srv/twbs % ll
total 12K
4.0K drwxr-xr-x. 2 jbellone jbellone 4.0K May 20 14:38 3.3.1/
4.0K drwxr-xr-x. 2 root     root     4.0K May 20 14:38 3.3.2/
4.0K drwxr-xr-x. 2 jbellone jbellone 4.0K May 20 14:38 3.3.4/
   0 lrwxrwxrwx. 1 root     root       15 May 20 14:38 current -> /srv/twbs/3.3.4/
```

## Requirements
- [libarchive cookbook][2]
- [Poise cookbook][5]

## Usage
Here is a simple recipe for installing the [Redis database][2]. This
will extract the files from the remote location to _/srv/redis/3.0.1_
and create a symbolic link from _/srv/redis/current_ to
_/srv/redis/3.0.1_.

```ruby
include_recipe 'build-essential::default'

source_version = '3.0.1'
download_url = "http://download.redis.io/releases/%{name}-%{version}.tar.gz"

group 'redis' do
  system true
end

user 'redis' do
  system true
  gid 'redis'
end

libartifact_file 'redis-3.0.1' do
  artifact_name 'redis'
  artifact_version '3.0.1'
  owner 'redis'
  group 'redis'
  remote_url download_url
  notifies :restart, 'service[redis-server]', :delayed
end

service 'redis-server' do
  supports :restart, :reload
  action [:create, :start]
end
```

It is important to note that the both the user and group *must*
exist. The resource does not make an attempt to create these. If you
want to restart a service you can do so using [Chef notifications][4].

## libartifact_file Resource/Provider
### Actions
| Name | Description |
| ---- | ----------- |
| create | Downloads and extracts a released artifact. |
| delete | Deletes a release artifact and unlinks the current symlink. |

### Parameters
| Key | Type | Description |
| --- | ---- | ----------- |
| artifact_name | String | Name of the release artifact. |
| artifact_version | String | Version of the release artifact. |
| install_path | String | Absolute path to the _base location_ for extracting release artifact. |
| binary_url | String, Array | Location(s) to download the release artifact. |
| binary_checksum | String | SHA256 checksum of the release artifact. |
| owner | String | Owner of the release artifact. |
| group | String | Group of the release artifact. |
| extract_options | Hash | [Extraction options][6] to pass into the [libarchive cookbook][2]. |

[1]: http://blog.vialstudios.com/the-environment-cookbook-pattern/#thelibrarycookbook
[2]: https://github.com/reset/libarchive-cookbook
[3]: http://redis.io
[4]: https://docs.chef.io/resource_common.html#notifications
[5]: https://github.com/poise/poise
[6]: https://github.com/reset/libarchive-cookbook#extract-options
