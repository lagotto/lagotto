# <a name="title"></a> golang (Chef cookbook for Go)

## <a name="description"></a> Description

Chef cookbook for [Go programming language](http://golang.org/).

## <a name="requirements"></a> Requirements

### <a name="requirements-platform"></a> Platform

* Ubuntu (12.04/13.04/14.10)
* Debian (6.0)

**Notes**: This cookbook has been tested on the listed platforms. It
may work on other platforms with or without modification. Please
[report issues](https://github.com/NOX73/chef-golang/issues) any additional platforms so they can be added.


## <a name="usage"></a> Usage

#### golang::default

Just include `golang` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[golang]"
  ]
}
```

#### golang::packages

To install Go packages using node attributes, include `golang::packages` in your node's `run_list`, and use the `['go']['packages']` attribute:

```json
{
  "name":"my_node",
  "go": {
    "packages": [
      "launchpad.net/gocheck"
    ]
  },
  "run_list": [
    "recipe[golang::packages]"
  ]
}
```


## <a name="attributes"></a> Attributes

#### golang::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['go']['version']</tt></td>
    <td>String</td>
    <td>Go version</td>
    <td><tt>1.4</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['platform']</tt></td>
    <td>String</td>
    <td>`amd64` or `i386`</td>
    <td><tt>amd64</tt></td>
  </tr>
    <tr>
    <td><tt>['go']['scm']</tt></td>
    <td>Boolean</td>
    <td>install SCM dependencies `git`, `hg`, and `bzr`</td>
    <td><tt>true</tt></td>
  </tr>
  </tr>
  <tr>
    <td><tt>['go']['packages']</tt></td>
    <td>Array</td>
    <td>Go packages to install when using the `golang::packages` recipe</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['owner']</tt></td>
    <td>String</td>
    <td>The user account that owns $GOPATH</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['group']</tt></td>
    <td>String</td>
    <td>The group that owns $GOPATH</td>
    <td><tt>root</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['mode']</tt></td>
    <td>String</td>
    <td>The mode of $GOPATH</td>
    <td><tt>0755</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['from_source']</tt></td>
    <td>Boolean</td>
    <td>Install go from source</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['os']</tt></td>
    <td>String</td>
    <td>Build go for which operating system</td>
    <td><tt>linux</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['arch']</tt></td>
    <td>String</td>
    <td>Build go for which architecture</td>
    <td><tt>arm</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['arm']</tt></td>
    <td>String</td>
    <td>Build go for which arm version</td>
    <td><tt>6</tt></td>
  </tr>
  <tr>
    <td><tt>['go']['source_method']</tt></td>
    <td>String</td>
    <td>Choose which install script should be used</td>
    <td><tt>all.bash</tt></td>
  </tr>
</table>

## <a name="testing"></a> Testing

This project have [foodcritic](https://github.com/acrmp/foodcritic) for syntax checking and
[test-kitchen](https://github.com/opscode/test-kitchen) for integration testing. You can run the test suite by
typing: `rake kitchen:all` (may be slow for the first time).

In order to run these tests, the following
[requirements](https://github.com/opscode/kitchen-vagrant#-requirements) must be
satisfied:

* [Vagrant](http://vagrantup.com/) (>= 1.1.0)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant Berkshelf Plugin](http://rubygems.org/gems/vagrant-berkshelf)

## <a name="contributing"></a> Contributing

1. Fork the repository
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Test it by running `rake kitchen:all`
5. Submit a Pull Request
