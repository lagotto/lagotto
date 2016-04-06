# Poise-Service Changelog

## v1.2.1

* [#23](https://github.com/poise/poise-service/pull/23) Fix service templates on AIX and FreeBSD to use the correct root group.

## v1.2.0

* The `Restart` mode for systemd services can now be controlled via provider
  option and defaults to `on-failure` to match other providers.

## v1.1.2

* [#22](https://github.com/poise/poise-service/pull/22) Set all script commands
  for the `sysvinit` provider. This should fix compatibility with EL5.

## v1.1.1

* Fix an incorrect value in `poise_service_test`. This is not relevant to
  end-users of `poise-service`.

## v1.1.0

* Added `inittab` provider to manage services using old-fashioned `/etc/inittab`.

## v1.0.4

* Set GID correctly in all service providers.
* Allow overriding the path to the generated sysvinit script.

## v1.0.3

* [#10](https://github.com/poise/poise-service/pull/10) Fixes for ensuring services are restarted when their command or user changes.
* [#11](https://github.com/poise/poise-service/pull/11) Revamp the `sysvinit` provider for non-Debian platforms to be more stable.
* [#12](https://github.com/poise/poise-service/pull/12) Improve the `dummy` provider to handle dropping privs correctly.

## v1.0.2

* Fix a potential infinite loop when starting a service with the dummy provider.
* [#2](https://github.com/poise/poise-service/pull/2) Remove usage of root
  default files so uploading with Berkshelf works (for now).

## v1.0.1

* Don't use a shared, mutable default value for `#environment`.

## v1.0.0

* Initial release!
