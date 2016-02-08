#
# Copyright 2015-2016, Noah Kantrowitz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'poise'

require 'poise_service/resources/poise_service'


module PoiseService
  # Mixin for application services. This is any resource that will be part of
  # an application deployment and involves running a persistent service.
  #
  # @since 1.0.0
  # @example
  #   module MyApp
  #     class Resource < Chef::Resource
  #       include Poise
  #       provides(:my_app)
  #       include PoiseService::ServiceMixin
  #     end
  #
  #     class Provider < Chef::Provider
  #       include Poise
  #       provides(:my_app)
  #       include PoiseService::ServiceMixin
  #
  #       def action_enable
  #         notifying_block do
  #           template '/etc/myapp.conf' do
  #             # ...
  #           end
  #         end
  #         super
  #       end
  #
  #       def service_options(r)
  #         r.command('myapp --serve')
  #       end
  #     end
  #   end
  module ServiceMixin
    include Poise::Utils::ResourceProviderMixin

    # Mixin for service wrapper resources.
    #
    # @see ServiceMixin
    module Resource
      include Poise::Resource

      module ClassMethods
        # @api private
        def included(klass)
          super
          klass.extend(ClassMethods)
          klass.class_exec do
            actions(:enable, :disable, :start, :stop, :restart, :reload)
            attribute(:service_name, kind_of: String, name_attribute: true)
          end
        end
      end

      extend ClassMethods
    end

    # Mixin for service wrapper providers.
    #
    # @see ServiceMixin
    module Provider
      include Poise::Provider

      # Default enable action for service wrappers.
      #
      # @return [void]
      def action_enable
        notify_if_service do
          service_resource.run_action(:enable)
        end
      end

      # Default disable action for service wrappers.
      #
      # @return [void]
      def action_disable
        notify_if_service do
          service_resource.run_action(:disable)
        end
      end

      # Default start action for service wrappers.
      #
      # @return [void]
      def action_start
        notify_if_service do
          service_resource.run_action(:start)
        end
      end

      # Default stop action for service wrappers.
      #
      # @return [void]
      def action_stop
        notify_if_service do
          service_resource.run_action(:stop)
        end
      end

      # Default restart action for service wrappers.
      #
      # @return [void]
      def action_restart
        notify_if_service do
          service_resource.run_action(:restart)
        end
      end

      # Default reload action for service wrappers.
      #
      # @return [void]
      def action_reload
        notify_if_service do
          service_resource.run_action(:reload)
        end
      end

      # @todo Add reload once poise-service supports it.

      private

      # Set the current resource as notified if the provided block updates the
      # service resource.
      #
      # @api public
      # @param block [Proc] Block to run.
      # @return [void]
      # @example
      #   notify_if_service do
      #     service_resource.run_action(:enable)
      #   end
      def notify_if_service(&block)
        service_resource.updated_by_last_action(false)
        block.call if block
        new_resource.updated_by_last_action(true) if service_resource.updated_by_last_action?
      end

      # Service resource for this service wrapper. This returns a
      # poise_service resource that will not be added to the resource
      # collection. Override {#service_options} to set service resource
      # parameters.
      #
      # @api public
      # @return [Chef::Resource]
      # @example
      #   service_resource.run_action(:restart)
      def service_resource
        @service_resource ||= PoiseService::Resources::PoiseService::Resource.new(new_resource.name, run_context).tap do |r|
          # Set some defaults.
          r.enclosing_provider = self
          r.source_line = new_resource.source_line
          r.service_name(new_resource.service_name)
          # Call the subclass hook for more specific settings.
          service_options(r)
        end
      end

      # Abstract hook to set parameters on {#service_resource} when it is
      # created. This is required to set at least `resource.command`.
      #
      # @api public
      # @param resource [Chef::Resource] Resource instance to set parameters on.
      # @return [void]
      # @example
      #   def service_options(resource)
      #     resource.command('myapp --serve')
      #   end
      def service_options(resource)
      end
    end
  end
end
