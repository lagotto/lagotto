#
# Copyright 2015, Noah Kantrowitz
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

require 'chef/provider'
require 'poise'


module PoiseService
  module ServiceProviders
    class Base < Chef::Provider
      include Poise(inversion: :poise_service)

      # Extend the default lookup behavior to check for service_name too.
      #
      # @api private
      def self.resolve_inversion_provider(node, resource)
        attrs = resolve_inversion_attribute(node)
        (attrs[resource.service_name] && attrs[resource.service_name]['provider']) || super
      end

      # Extend the default options to check for service_name too.
      #
      # @api private
      def self.inversion_options(node, resource)
        super.tap do |opts|
          attrs = resolve_inversion_attribute(node)
          opts.update(attrs[resource.service_name]) if attrs[resource.service_name]
          run_state = Mash.new(node.run_state.fetch('poise_inversion', {}).fetch(inversion_resource, {}))[resource.service_name] || {}
          opts.update(run_state['*']) if run_state['*']
          opts.update(run_state[provides]) if run_state[provides]
        end
      end

      # Cache the service hints to improve performance. This is called from the
      # provides_auto? on most service providers and hits the filesystem a lot.
      #
      # @return [Array<Symbol>]
      def self.service_resource_hints
        @@service_resource_hints ||= Chef::Platform::ServiceHelpers.service_resource_providers
      end

      def action_enable
        include_recipe(*Array(recipes)) if recipes
        notifying_block do
          create_service
        end
        enable_service
        action_start
      end

      def action_disable
        action_stop
        disable_service
        notifying_block do
          destroy_service
        end
      end

      def action_start
        notify_if_service do
          service_resource.run_action(:start)
        end
      end

      def action_stop
        notify_if_service do
          service_resource.run_action(:stop)
        end
      end

      def action_restart
        return if options['never_restart']
        notify_if_service do
          service_resource.run_action(:restart)
        end
      end

      def action_reload
        return if options['never_reload']
        notify_if_service do
          service_resource.run_action(:reload)
        end
      end

      def pid
        raise NotImplementedError
      end

      private

      # Recipes to include for this provider to work. Subclasses can override.
      #
      # @return [String, Array]
      def recipes
      end

      # Subclass hook to create the required files et al for the service.
      def create_service
        raise NotImplementedError
      end

      # Subclass hook to remove the required files et al for the service.
      def destroy_service
        raise NotImplementedError
      end

      def enable_service
        notify_if_service do
          service_resource.run_action(:enable)
        end
      end

      def disable_service
        notify_if_service do
          service_resource.run_action(:disable)
        end
      end

      def notify_if_service(&block)
        service_resource.updated_by_last_action(false)
        block.call
        new_resource.updated_by_last_action(true) if service_resource.updated_by_last_action?
      end

      # Subclass hook to create the resource used to delegate start, stop, and
      # restart actions.
      def service_resource
        @service_resource ||= Chef::Resource::Service.new(new_resource.service_name, run_context).tap do |r|
          r.enclosing_provider = self
          r.source_line = new_resource.source_line
          r.supports(status: true, restart: true, reload: true)
        end
      end

      def service_template(path, default_source, &block)
        # Sigh scoping.
        template path do
          owner 'root'
          group 'root'
          mode '644'
          if options['template']
            # If we have a template override, allow specifying a cookbook via
            # "cookbook:template".
            parts = options['template'].split(/:/, 2)
            if parts.length == 2
              source parts[1]
              cookbook parts[0]
            else
              source parts.first
              cookbook new_resource.cookbook_name.to_s
            end
          else
            source default_source
            cookbook 'poise-service'
          end
          variables(
            command: options['command'] || new_resource.command,
            directory: options['directory'] || new_resource.directory,
            environment: options['environment'] || new_resource.environment,
            name: new_resource.service_name,
            new_resource: new_resource,
            options: options,
            reload_signal: options['reload_signal'] || new_resource.reload_signal,
            stop_signal: options['stop_signal'] || new_resource.stop_signal,
            user: options['user'] || new_resource.user,
          )
          # Don't trigger a restart if the template doesn't already exist, this
          # prevents restarting on the run that first creates the service.
          restart_on_update = options.fetch('restart_on_update', new_resource.restart_on_update)
          if restart_on_update && ::File.exist?(path)
            mode = restart_on_update.to_s == 'immediately' ? :immediately : :delayed
            notifies :restart, new_resource, mode
          end
          instance_exec(&block) if block
        end
      end

    end
  end
end
