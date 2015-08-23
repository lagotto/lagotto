selinux Cookbook CHANGELOG
==========================

v0.9.0 (2015-02-22)
-------------------
- Initial Debian / Ubuntu support
- Various bug fixes

v0.8.0 (2014-04-23)
-------------------
- [COOK-4528] - Fix selinux directory permissions
- [COOK-4562] - Basic support for Ubuntu/Debian


v0.7.2 (2014-03-24)
-------------------
handling minimal installs


v0.7.0 (2014-02-27)
-------------------
[COOK-4218] Support setting SELinux boolean values


v0.6.2
------
- Fixing bug introduced in 0.6.0 
- adding basic test-kitchen coverage


v0.6.0
------
- [COOK-760] - selinux enforce/permit/disable based on attribute


v0.5.6
------
- [COOK-2124] - enforcing recipe fails if selinux is disabled

v0.5.4
------
- [COOK-1277] - disabled recipe fails on systems w/o selinux installed

v0.5.2
------
- [COOK-789] - fix dangling commas causing syntax error on some rubies

v0.5.0
------
- [COOK-678] - add the selinux cookbook to the repository
- Use main selinux config file (/etc/selinux/config)
- Use getenforce instead of selinuxenabled for enforcing and permissive
