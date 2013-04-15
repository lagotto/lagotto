name              "alm"
maintainer        "Martin Fenner"
maintainer_email  "mfenner@plos.org"
license           "Apache 2.0"
description       "Configures ALM server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "1.0.3"
depends           "build-essential"
depends           "git"
depends           "mysql"
depends           "couchdb"
depends           "phantomjs"
depends           "passenger_apache2"

%w{ ubuntu centos }.each do |platform|
  supports platform
end