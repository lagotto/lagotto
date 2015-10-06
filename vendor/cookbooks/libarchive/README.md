# libarchive-cookbook

A library cookbook that provides LWRPs for extracting archive files

## Requirements

* Chef ~> 12.1

## Supported Platforms

* Ubuntu
* CentOS (RHEL)
* Arch Linux

## Usage

```ruby
include_recipe "libarchive::default"

libarchive_file "my_archive.tar.gz" do
  path "/path/to/artifact/my_archive.tar.gz"
  extract_to "/path/to/extraction"
  owner "reset"
  group "reset"

  action :extract
end
```

## Recipes

### libarchive::default

Include this recipe before leveraging any of the LWRPs provided by this cookbook. It will install the necessary libarchive packages on your node and the necessary libarchive rubygem as a chef_gem.

## libarchive_file Resource/Provider

### Actions

- **extract** - extracts the contents of the archive to the destination on disk. (default)

### Paramter Attributes

- **path** - filepath to the archive to extract (name attribute)
- **owner** - set the owner of the extracted files
- **group** - set the group of the extracted files
- **mode** - set the mode of the extracted files
- **extract_to** - filepath to extract the contents of the archive to
- **extract_options** - an array of symbols representing extraction flags. See extract options below.

### Extract Options

- `:no_overwrite` - don't overwrite files if they already exist

## License and Authors

Author:: Jamie Winsor (<jamie@vialstudios.com>)
Author:: John Bellone (<jbellone@bloomberg.net>)
