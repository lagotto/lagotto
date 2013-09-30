#
# Author:: Joshua Timberman <joshua@opscode.com>
# Copyright:: Copyright (c) 2009, Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Generic cookbook attributes
default['postfix']['mail_type']  = "client"
default['postfix']['relayhost_role'] = "relayhost"
default['postfix']['multi_environment_relay'] = false
default['postfix']['use_procmail'] = false
default['postfix']['aliases'] = {}
default['postfix']['main_template_source'] = "postfix"
default['postfix']['master_template_source'] = "postfix"

# Non-default main.cf attributes
default['postfix']['main']['biff'] = "no"
default['postfix']['main']['append_dot_mydomain'] = "no"
default['postfix']['main']['myhostname'] = node['fqdn']
default['postfix']['main']['mydomain'] = node['domain']
default['postfix']['main']['myorigin'] = "$myhostname"
default['postfix']['main']['mydestination'] = [ node['postfix']['main']['myhostname'], node['hostname'], "localhost.localdomain", "localhost" ]
default['postfix']['main']['smtpd_use_tls'] = "yes"
default['postfix']['main']['smtp_use_tls'] = "yes"
default['postfix']['main']['alias_maps'] = [ "hash:/etc/aliases" ]
default['postfix']['main']['mailbox_size_limit'] = 0
default['postfix']['main']['recipient_delimiter'] = "+"
default['postfix']['main']['smtp_sasl_auth_enable'] = "no"
default['postfix']['main']['mynetworks'] = "127.0.0.0/8"
default['postfix']['main']['inet_interfaces'] = "loopback-only"

# Conditional attributes
case node['platform_family']
when "rhel"
  cafile = "/etc/pki/tls/cert.pem"
else
  cafile = "/etc/postfix/cacert.pem"
end

if node['postfix']['use_procmail']
  default['postfix']['main']['mailbox_command'] = '/usr/bin/procmail -a "$EXTENSION"'
end

if node['postfix']['main']['smtpd_use_tls'] == "yes"
  default['postfix']['main']['smtpd_tls_cert_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
  default['postfix']['main']['smtpd_tls_key_file'] = "/etc/ssl/private/ssl-cert-snakeoil.key"
  default['postfix']['main']['smtpd_tls_CAfile'] = cafile
  default['postfix']['main']['smtpd_tls_session_cache_database'] = "btree:${data_directory}/smtpd_scache"
end

if node['postfix']['main']['smtp_use_tls'] == "yes"
  default['postfix']['main']['smtp_tls_CAfile'] = cafile
  default['postfix']['main']['smtp_tls_session_cache_database'] = "btree:${data_directory}/smtp_scache"
end

if node['postfix']['main']['smtp_sasl_auth_enable'] == "yes"
  default['postfix']['main']['smtp_sasl_password_maps'] = "hash:/etc/postfix/sasl_passwd"
  default['postfix']['main']['smtp_sasl_security_options'] = "noanonymous"
  default['postfix']['sasl']['smtp_sasl_user_name'] = ""
  default['postfix']['sasl']['smtp_sasl_passwd']    = ""
  default['postfix']['main']['relayhost'] = ""
end

# Default main.cf attributes according to `postconf -d`
#default['postfix']['main']['relayhost'] = ""
#default['postfix']['main']['milter_default_action']  = "tempfail"
#default['postfix']['main']['milter_protocol']  = "6"
#default['postfix']['main']['smtpd_milters']  = ""
#default['postfix']['main']['non_smtpd_milters']  = ""
#default['postfix']['main']['sender_canonical_classes'] = nil
#default['postfix']['main']['recipient_canonical_classes'] = nil
#default['postfix']['main']['canonical_classes'] = nil
#default['postfix']['main']['sender_canonical_maps'] = nil
#default['postfix']['main']['recipient_canonical_maps'] = nil
#default['postfix']['main']['canonical_maps'] = nil

# Master.cf attributes
default['postfix']['master']['submission'] = false
