name              "alm"
maintainer        "Martin Fenner"
maintainer_email  "mfenner@plos.org"
license           "Apache 2.0"
description       "Configures ALM server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.2"
depends           "build-essential"
depends           "git"
depends           "mysql"
depends           "couchdb"
depends           "phantomjs"

%w{ ubuntu centos }.each do |platform|
  supports platform
end