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

require 'etc'

require 'chef/mash'
require 'chef/resource'
require 'poise'

require 'poise_service/error'


module PoiseService
  module Resources
    # (see PoiseService::Resource)
    module PoiseService
      # `poise_service` resource. Provides a unified service interface with a
      # dependency injection framework.
      #
      # @since 1.0.0
      # @provides poise_service
      # @action enable
      # @action disable
      # @action start
      # @action stop
      # @action restart
      # @action reload
      # @example
      #   poise_service 'myapp' do
      #     command 'myapp --serve'
      #     user 'myuser'
      #     directory '/home/myapp'
      #   end
      class Resource < Chef::Resource
        include Poise(inversion: true)
        provides(:poise_service)
        actions(:enable, :disable, :start, :stop, :restart, :reload)

        # @!attribute service_name
        #   Name of the service to the underlying init system. Defaults to the name
        #   of the resource.
        #   @return [String]
        attribute(:service_name, kind_of: String, name_attribute: true)
        # @!attribute command
        #   Command to run inside the service. This command must remain in the
        #   foreground and not daemoinize itself.
        #   @return [String]
        attribute(:command, kind_of: String, required: true)
        # @!attribute user
        #   User to run the service as. See {UserResource} for an easy way to
        #   create service users. Defaults to root.
        #   @return [String]
        attribute(:user, kind_of: String, default: 'root')
        # @!attribute directory
        #   Working directory for the service. Defaults to the home directory of
        #   the configured user or / if not found.
        #   @return [String]
        attribute(:directory, kind_of: String, default: lazy { default_directory })
        # @!attribute environment
        #   Environment variables for the service.
        #   @return [Hash]
        attribute(:environment, kind_of: Hash, default: lazy { Mash.new })
        # @!attribute stop_signal
        #   Signal to use to stop the service. Some systems will fall back to
        #   KILL if this signal fails to stop the process. Defaults to TERM.
        #   @return [String, Symbol, Integer]
        attribute(:stop_signal, kind_of: [String, Symbol, Integer], default: 'TERM')
        # @!attribute reload_signal
        #   Signal to use to reload the service. Defaults to HUP.
        #   @return [String, Symbol, Integer]
        attribute(:reload_signal, kind_of: [String, Symbol, Integer], default: 'HUP')
        # @!attribute restart_on_update
        #   If true, the service will be restarted if the service definition or
        #   configuration changes. If 'immediately', the notification will happen
        #   in immediate mode.
        #   @return [Boolean, String]
        attribute(:restart_on_update, equal_to: [true, false, 'immediately', :immediately], default: true)

        # Resource DSL callback.
        #
        # @api private
        def after_created
          # Set signals to clean values.
          stop_signal(clean_signal(stop_signal))
          reload_signal(clean_signal(reload_signal))
        end

        # Return the PID of the main process for this service or nil if the service
        # isn't running or the PID cannot be found.
        #
        # @return [Integer, nil]
        # @example
        #   execute "kill -WINCH #{resources('poise_test[myapp]').pid}"
        def pid
          # :pid isn't a real action, but this should still work.
          provider_for_action(:pid).pid
        end

        private

        # Try to find the home diretory for the configured user. This will fail if
        # nsswitch.conf was changed during this run such as with LDAP. Defaults to
        # the system root directory.
        #
        # @see #directory
        # @return [String]
        def default_directory
          # For root we always want the system root path.
          unless user == 'root'
            # Force a reload in case any users were created earlier in the run.
            Etc.endpwent
            home = begin
              Dir.home(user)
            rescue ArgumentError
              nil
            end
          end
          # Better than nothing
          home || case node['platform_family']
          when 'windows'
            ENV.fetch('SystemRoot', 'C:\\')
          else
            '/'
          end
        end

        # Clean up a signal string/integer. Ints are mapped to the signal name,
        # and strings are reformatted to upper case and without the SIG.
        #
        # @see #stop_signal
        # @param signal [String, Symbol, Integer] Signal value to clean.
        # @return [String]
        def clean_signal(signal)
          if signal.is_a?(Integer)
            raise Error.new("Unknown signal #{signal}") unless (0..31).include?(signal)
            Signal.signame(signal)
          else
            short_sig = signal.to_s.upcase
            short_sig = short_sig[3..-1] if short_sig.start_with?('SIG')
            raise Error.new("Unknown signal #{signal}") unless Signal.list.include?(short_sig)
            short_sig
          end
        end

        # Providers can be found under service_providers/.
      end
    end
  end
end
