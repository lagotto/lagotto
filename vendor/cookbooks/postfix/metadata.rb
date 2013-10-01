name              "postfix"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs and configures postfix for client or outbound relayhost, or to do SASL auth"
version           "3.0.0"
recipe            "postfix", "Installs and configures postfix"
recipe            "postfix::sasl_auth", "Set up postfix to auth to a server with sasl"
recipe            "postfix::aliases", "Manages /etc/aliases"
recipe            "postfix::client", "Searches for the relayhost based on an attribute"
recipe            "postfix::server", "Sets the mail_type attribute to master"

%w{ubuntu debian redhat centos amazon scientific}.each do |os|
  supports os
end

attribute "postfix/main",
  :display_name => "postfix/main",
  :description => "Hash of Postfix main.cf attributes",
  :type => "hash"

attribute "postfix/aliases",
  :display_name => "Postfix Aliases",
  :description => "Hash of Postfix aliases mapping a name to a value.  Example 'root' => 'operator@example.com'.  See aliases man page for details.",
  :type => "hash"

attribute "postfix/mail_type",
  :display_name => "Postfix Mail Type",
  :description => "Is this node a client or server?",
  :default => "client"

attribute "postfix/smtp_sasl_user_name",
  :display_name => "Postfix SMTP SASL Username",
  :description => "User to auth SMTP via SASL",
  :default => ""

attribute "postfix/smtp_sasl_passwd",
  :display_name => "Postfix SMTP SASL Password",
  :description => "Password for smtp_sasl_user_name",
  :default => ""

attribute "postfix/relayhost_role",
  :display_name => "Postfix Relayhost's role",
  :description => "String containing the role name",
  :default => "relayhost"

attribute "postfix/use_procmail",
  :display_name => "Postfix Use procmail?",
  :description => "Whether procmail should be used as the local delivery agent for a server",
  :default => "no"
