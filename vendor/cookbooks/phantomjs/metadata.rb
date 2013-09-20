name 'phantomjs'
maintainer 'Seth Vargo'
maintainer_email 'sethvargo@gmail.com'
license 'Apache 2.0'
description 'Installs/Configures phantomjs'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.2'

%w(amazon centos debian fedora gentoo oracle rhel scientific ubuntu windows).each do |os|
  supports os
end

depends 'build-essential'
depends 'chocolatey'
