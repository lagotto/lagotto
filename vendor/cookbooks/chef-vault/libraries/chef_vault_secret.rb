#
# Author:: Joshua Timberman <joshua@chef.io>
# Copyright:: Copyright (c) 2014, Chef Software, Inc. <legal@chef.io>
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
#
require 'chef/provider/lwrp_base'
require 'chef/resource/lwrp_base'
begin
  require 'chef-vault'
rescue LoadError
  Chef::Log.debug("could not load chef-vault whilst loading #{__FILE__}, it should be")
  Chef::Log.debug('available after running the chef-vault recipe.')
end

module ChefVaultCookbook
  module Resource
    class ChefVaultSecret < Chef::Resource::LWRPBase
      self.resource_name = 'chef_vault_secret'
      provides(:chef_vault_secret) if defined?(provides)

      actions(:create, :create_if_missing, :update, :delete)
      default_action(:create)

      attribute(:id, kind_of: String, name_attribute: true)
      attribute(:data_bag, kind_of: String, required: true)
      attribute(:admins, kind_of: [String, Array], required: true)
      attribute(:clients, kind_of: [String, Array])
      attribute(:search, kind_of: String, default: '*:*')
      attribute(:raw_data, kind_of: [Hash, Mash], default: {})
      attribute(:environment, kind_of: [String, NilClass], default: nil)
    end
  end

  module Provider
    class ChefVaultSecret < Chef::Provider::LWRPBase
      provides(:chef_vault_secret) if defined?(provides)
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def load_current_resource
        json = ChefVault::Item.load(new_resource.data_bag, new_resource.id)
        @current_resource = Chef::Resource::ChefVaultSecret.new(new_resource.id)
        @current_resource.search(new_resource.search)
        @current_resource.admins(new_resource.admins)
        @current_resource.data_bag(new_resource.data_bag)
        @current_resource.raw_data(json.to_hash)
        @current_resource
      rescue ChefVault::Exceptions::KeysNotFound
        @current_resource = nil
      rescue Net::HTTPServerException => e
        @current_resource = nil if e.response_code == '404'
        raise
      rescue OpenSSL::PKey::RSAError
        raise "#{$ERROR_INFO.message} - on #{Chef::Config[:client_key]}, is the vault item encrypted with this client/user?"
      end

      action :create do
        converge_by("create #{new_resource.id} in #{new_resource.data_bag} with Chef::Vault") do
          item = ChefVault::Item.new(new_resource.data_bag, new_resource.id)

          Chef::Log.debug("#{new_resource.id} environment: '#{new_resource.environment}'")
          item.raw_data = if new_resource.environment.nil?
                            new_resource.raw_data.merge('id' => new_resource.id)
                          else
                            { 'id' => new_resource.id, new_resource.environment => new_resource.raw_data }
                          end

          Chef::Log.debug("#{new_resource.id} search query: '#{new_resource.search}'")
          item.search(new_resource.search)
          Chef::Log.debug("#{new_resource.id} clients: '#{new_resource.clients}'")
          item.clients([new_resource.clients].flatten.join(',')) unless new_resource.clients.nil?
          Chef::Log.debug("#{new_resource.id} admins (users): '#{new_resource.admins}'")
          item.admins([new_resource.admins].flatten.join(','))
          item.save

          new_resource.updated_by_last_action(true)
        end
      end

      action :create_if_missing do
        action_create if @current_resource.nil?
      end

      action :delete do
        converge_by("remove #{new_resource.id} and #{new_resource.id}_keys from #{new_resource.data_bag}") do
          chef_data_bag_item new_resource.id do
            action :delete
          end

          chef_data_bag_item [new_resource.id, 'keys'].join('_') do
            action :delete
          end
        end
      end
    end
  end
end
