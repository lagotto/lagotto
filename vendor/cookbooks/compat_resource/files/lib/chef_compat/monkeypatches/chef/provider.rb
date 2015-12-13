require 'chef/provider'
require 'chef/provider/lwrp_base'

class Chef::Provider
  if !defined?(InlineResources)
    InlineResources = Chef::Provider::LWRPBase::InlineResources
  end
  module InlineResources
    require 'chef/dsl/recipe'
    require 'chef/dsl/platform_introspection'
    require 'chef/dsl/data_query'
    require 'chef/dsl/include_recipe'
    include Chef::DSL::Recipe
    include Chef::DSL::PlatformIntrospection
    include Chef::DSL::DataQuery
    include Chef::DSL::IncludeRecipe

    module ::ChefCompat
      module Monkeypatches
        module InlineResources
          module ClassMethods
            def action(name, &block)
              super(name) { send("compile_action_#{name}") }
              # We put the action in its own method so that super() works.
              define_method("compile_action_#{name}", &block)
            end
          end
        end
      end
    end
    module ClassMethods
      prepend ChefCompat::Monkeypatches::InlineResources::ClassMethods
    end
  end
end
