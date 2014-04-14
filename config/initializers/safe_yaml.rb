require 'psych'
require 'safe_yaml'

SafeYAML::OPTIONS[:default_mode] = :safe
SafeYAML::OPTIONS[:deserialize_symbols] = true
SafeYAML::OPTIONS[:whitelisted_tags] = ["!ruby/object:OpenStruct"]
