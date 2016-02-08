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

require 'etc'
require 'shellwords'

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
          now = Time.now
          until ::File.exist?(pid_file)
            sleep(1)
            # After 30 seconds, show output at a higher level to avoid too much
            # confusing on failed process launches.
            if Time.now - now <= 30
              Chef::Log.debug("[#{new_resource}] Waiting for PID file")
            else
              Chef::Log.warning("[#{new_resource}] Waiting for PID file at #{pid_file} to be created")
            end
          end
        else
          # :nocov:
          Chef::Log.debug("[#{new_resource}] Forked")
          # First child, daemonize and go to town. This handles multi-fork,
          # setsid, and shutting down stdin/out/err.
          Process.daemon(true)
          Chef::Log.debug("[#{new_resource}] Daemonized")
          # Daemonized, set up process environment.
          Dir.chdir(new_resource.directory)
          Chef::Log.debug("[#{new_resource}] Directory changed to #{new_resource.directory}")
          ENV['HOME'] = Dir.home(new_resource.user)
          new_resource.environment.each do |key, val|
            ENV[key.to_s] = val.to_s
          end
          Chef::Log.debug("[#{new_resource}] Process environment configured")
          IO.write(pid_file, Process.pid)
          Chef::Log.debug("[#{new_resource}] PID written to #{pid_file}")
          ent = Etc.getpwnam(new_resource.user)
          if Process.euid != ent.uid || Process.egid != ent.gid
            Process.initgroups(ent.name, ent.gid)
            Process::GID.change_privilege(ent.gid) if Process.egid != ent.gid
            Process::UID.change_privilege(ent.uid) if Process.euid != ent.uid
          end
          Chef::Log.debug("[#{new_resource}] Changed privs to #{new_resource.user} (#{ent.uid}:#{ent.gid})")
          # Split the command so we don't get an extra sh -c.
          Chef::Log.debug("[#{new_resource}] Execing #{new_resource.command}")
          Kernel.exec(*Shellwords.split(new_resource.command))
          # Just in case, bail out.
          exit!
          # :nocov:
        end
        Chef::Log.debug("[#{new_resource}] Started.")
      end

      def action_stop
        return unless pid
        Chef::Log.debug("[#{new_resource}] Stopping with #{new_resource.stop_signal}. Current PID is #{pid.inspect}.")
        Process.kill(new_resource.stop_signal, pid)
        ::File.unlink(pid_file)
      end

      def action_restart
        return if options['never_restart']
        action_stop
        action_start
      end

      def action_reload
        return if options['never_reload']
        return unless pid
        Chef::Log.debug("[#{new_resource}] Reloading with #{new_resource.reload_signal}. Current PID is #{pid.inspect}.")
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

      # Write all major service parameters to a file so that if they change, we
      # can restart the service. This also makes debuggin a bit easier so you
      # can still see what it thinks it was starting without sifting through
      # piles of debug output.
      def create_service
        service_template(run_file, 'dummy.json.erb')
      end

      def disable_service
      end

      # Delete the tracking file.
      def destroy_service
        file run_file do
          action :delete
        end

        file pid_file do
          action :delete
        end
      end

      # Path to the run parameters tracking file.
      def run_file
        "/var/run/#{new_resource.service_name}.json"
      end

      # Path to the PID file.
      def pid_file
        "/var/run/#{new_resource.service_name}.pid"
      end

    end
  end
end
