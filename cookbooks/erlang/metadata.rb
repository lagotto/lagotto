name             "erlang"
maintainer        "Opscode, Inc."
maintainer_email  "cookbooks@opscode.com"
license           "Apache 2.0"
description       "Installs erlang, optionally install GUI tools."
version           "1.2.0"
depends           "yum", ">= 0.5.0"
depends           "build-essential"

recipe "erlang", "Installs Erlang via package or source"
recipe "erlang::package", "Installs Erlang via package"
recipe "erlang::source", "Installs Erlang via source"

%w{ ubuntu debian redhat centos scientific amazon oracle }.each do |os|
  supports os
end
