phantomjs Cookbook
==================
[![Build Status](https://secure.travis-ci.org/customink-webops/phantomjs.png?branch=master)](http://travis-ci.org/customink-webops/phantomjs)

Installs the phantomjs cookbook and necessary packages. This repository also features a full test suite!

**As of version 1.0.0, this cookbook is Chef 11!+**

Installation
------------
Add the `phamtomjs` cookbook to your `Berksfile`:

```ruby
cookbook 'phantomjs'
```

or install directly with knife:

    $ knife cookbook site install phantomjs

Usage
-----
Add the cookbook to your `run_list` in a node or role:

```ruby
"run_list": [
  "recipe[phantomjs::default]"
]
```

or include it in a recipe:

```ruby
# other_cookbook/metadata.rb
# ...
depends 'phantomjs'
```
```ruby
# other_cookbook/recipes/default.rb
# ...
include_recipe 'phantomjs::default'
```

Attributes
----------
All attributes are namespaced under `node['phantomjs']`.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Example</th>
      <th>Default</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>version</td>
      <td>The version to install</td>
      <td><tt>1.0.0</tt></td>
      <td><tt>1.9.2</tt></td>
    </tr>
    <tr>
      <td>packages</td>
      <td>The supporting packages</td>
      <td><tt>['apache2']</td>
      <td>(varies)</td>
    </tr>
    <tr>
      <td>checksum</td>
      <td>The checksum of the download</td>
      <td><tt>abc123</tt></td>
      <td><tt>nil</tt></td>
    </tr>
    <tr>
      <td>src_dir</td>
      <td>Location for the download</td>
      <td><tt>/src</tt></td>
      <td><tt>/usr/local/src</tt></td>
    </tr>
    <tr>
      <td>base_url</td>
      <td>URL for download</td>
      <td><tt>http://example.com/</tt></td>
      <td><tt>https://phantomjs.googlecode.com/files</tt></td>
    </tr>
    <tr>
      <td>basename</td>
      <td>Name of the package</td>
      <td><tt>phantomjs-1.0.0-x86</tt></td>
      <td>(varies)</td>
    </tr>
  </tbody>
</table>

Development
-----------
1. Fork the project
1. Create a feature branch (i.e. `add_feature_x`)
1. Make your changes
1. Write or change specs as necessary
1. Run the tests:

        $ bundle exec strainer test

1. Submit a pull request on github

License and Authors
-------------------
- Author: Seth Vargo (sethvargo@gmail.com)

```text
Copyright 2012-2013, Seth Vargo
Copyright 2012-2013, CustomInk, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
