# xfs Cookbook CHANGELOG
This file is used to list changes made in each version of the xfs cookbook.

## v2.0.1
- Marked this cookbook as deprecated. See the readme for additional information

## v2.0.0
- Dev packages are no longer installed unless node['xfs']['dev_packages'] is true
- Add chefspec and serverspec tests

## v1.1.1:
- Added support for Oracle Linux to the metadata
- Added gitignore and chefignore files
- Added Test Kitchen config
- Added Rubocop config
- Added Travis config
- Added Berksfile
- Updated Testing and Contributing docs
- Added maintainers.toml and maintainers.md files
- Added Gemfile with development dependencies
- Added Travis and cookbook version badges to the Readme
- Expanded the requirements section in the Readme
- Added a Rakefile for simplified testing
- Added issues_url and source_url to the metadata.rb
- Updated Opscode -> Chef Software
- Added basic Chefspec converge test
- Resolved all Rubocop warnings

## v1.1.0:
- [COOK-2076] - Add Amazon Linux support
