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

require 'poise_service/service_providers/base'


module PoiseService
  module ServiceProviders
    class Dummy < Base
      provides(:dummy)

      def action_start
        return if pid
        Chef::Log.debug("[#{new_resource}] Starting #{new_resource.command}")
        # Clear the pid file if it exists.
        ::File.unlink(pid_file) if ::File.exist?(pid_file)
        if Process.fork
          # Parent, wait for the final child to write the pid file.
          until ::File.exist?(pid_file)
            sleep(1)
            Chef::Log.debug("[#{new_resource}] Waiting for PID file")
          end
        else
          # :nocov:
          Chef::Log.debug("[#{new_resource}] Forked")
          # First child, daemonize and go to town.
          Process.daemon(true)
          Chef::Log.debug("[#{new_resource}] Daemonized")
          # Daemonized, set up process environment.
          Dir.chdir(new_resource.directory)
          Chef::Log.debug("[#{new_resource}] Directory changed to #{new_resource.directory}")
          new_resource.environment.each do |key, val|
            ENV[key.to_s] = val.to_s
          end
          Process.uid = new_resource.user
          Chef::Log.debug("[#{new_resource}] Process environment configured")
          IO.write(pid_file, Process.pid)
          Chef::Log.debug("[#{new_resource}] PID written to #{pid_file}, execing #{new_resource.command}")
          Kernel.exec(new_resource.command)
          # Just in case, bail out.
          exit!
          # :nocov:
        end
        Chef::Log.debug("[#{new_resource}] Started.")
      end

      def action_stop
        return unless pid
        Process.kill(new_resource.stop_signal, pid)
        ::File.unlink(pid_file)
      end

      def action_restart
        action_stop
        action_start
      end

      def action_reload
        Process.kill(new_resource.reload_signal, pid)
      end

      def pid
        return nil unless ::File.exist?(pid_file)
        pid = IO.read(pid_file).to_i
        begin
          # Check if the PID is running.
          Process.kill(0, pid)
          pid
        rescue Errno::ESRCH
          nil
        end
      end

      private

      def service_resource
        # Intentionally not implemented.
        raise NotImplementedError
      end

      def enable_service
      end

      def create_service
      end

      def disable_service
      end

      def destroy_service
      end

      def pid_file
        "/var/run/#{new_resource.service_name}.pid"
      end

    end
  end
end
