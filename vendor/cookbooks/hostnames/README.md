# hostnames cookbook

Easy `hostname`, FQDN and `/etc/hosts` file updates. Less broken than the [hostname](https://github.com/3ofcoins/chef-cookbook-hostname) recipe.

Works with custom `/etc/hosts` files and fixes aws dns slowness (use `use_node_ip: true`)

https://github.com/nathantsoi/chef-cookbook-hostname

## Install it

With [berkshelf](http://berkshelf.com/) - `Berskfile`

```ruby
source 'https://supermarket.getchef.com'
...
cookbook 'hostnames'
```

## Example

Run via a role - `roles/base.rb`

```ruby
name 'base'
description 'Standard Sequoia setup'
run_list(
  'recipe[hostnames::default]',
  ...
)
default_attributes(
  set_fqdn: '*.sequoiacap.com',
  hostname_cookbook: {
    use_node_ip: true
  },
  ...
)
```

## Attributes

- `node['set_fqdn']` - FQDN to set.

The asterisk character will be replaced with `node.name`. This way,
you can add this to base role:

```ruby
default_attributes :set_fqdn => '*.project-domain.com'
```

and have node set its FQDN and hostname based on its chef node name
(which is provided on `chef-client` first run's command line).

- `node['hostname_cookbook']['use_node_ip']` -- when true
  sets the hostname to ```node["ipaddress"]``` in ```/etc/hosts``` (default: `false`)

- `node['hostname_cookbook']['hostsfile_ip']` -- IP used in
  `/etc/hosts` to correctly set FQDN (default: `127.0.1.1`)


## Recipes

* `hostnames::default` -- will set node's FQDN to value of `set_fqdn` attribute,
and hostname to its host part (up to first dot).

* `hostnames::vmware` -- sets hostname automatically using vmtoolsd.
You do not need to set `node["set_fqdn"]`.

## Contributing

* Fork.

* Make more awesome.

* Pull request.

* I will bump version and run: ```knife cookbook site share hostnames "Networking" -o ../```

## Author

(original) Maciej Pasternacki maciej@3ofcoins.net

(current) [Nathan](http://nathan.vertile.com) nathan@vertile.com
