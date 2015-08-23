#
# Cookbook Name:: libarchive
# Resource:: file
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

actions :extract
default_action :extract

attribute :path, kind_of: String, name_attribute: true, required: true
attribute :owner, kind_of: String
attribute :group, kind_of: String
attribute :mode, kind_of: Integer, default: 0755
attribute :extract_to, kind_of: String, required: true
attribute :extract_options, kind_of: [Array, Symbol], default: Array.new
