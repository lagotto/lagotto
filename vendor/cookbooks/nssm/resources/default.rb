actions :install, :remove
default_action :install

attribute :servicename, name_attribute: true
attribute :program, kind_of: String, required: true
attribute :args, kind_of: String
attribute :params, kind_of: Hash, default: {}
attribute :start, kind_of: [TrueClass, FalseClass], default: true
