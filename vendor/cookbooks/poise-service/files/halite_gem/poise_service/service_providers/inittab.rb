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

require 'chef/util/file_edit'

require 'poise_service/service_providers/base'


module PoiseService
  module ServiceProviders
    class Inittab < Base
      provides(:inittab)

      def self.provides_auto?(node, resource)
        ::File.exist?('/etc/inittab')
      end

      def pid
        IO.read(pid_file).to_i if ::File.exist?(pid_file)
      end

      # Don't try to stop when disabling because we can't.
      def action_disable
        disable_service
        notifying_block do
          destroy_service
        end
      end

      def action_start
        Chef::Log.debug("[#{new_resource}] Inittab services are always started.")
      end

      def action_stop
        raise NotImplementedError.new("[#{new_resource}] Inittab services cannot be stopped")
      end

      def action_restart
        return if options['never_restart']
        # Just kill it and let init restart it.
        Process.kill(new_resource.stop_signal, pid) if pid
      end

      def action_reload
        return if options['never_reload']
        Process.kill(new_resource.reload_signal, pid) if pid
      end

      private

      def service_resource
        # Intentionally not implemented.
        raise NotImplementedError
      end

      def enable_service
      end

      def disable_service
      end

      def create_service
        # Sigh scoping.
        pid_file_ = pid_file
        # Inittab only allows 127 characters for the command, so cram stuff in
        # a file. Writing to a file is gross, but so is using inittab so ¯\_(ツ)_/¯.
        service_template("/sbin/poise_service_#{new_resource.service_name}", 'inittab.sh.erb') do
          mode '755'
          variables.update(
            pid_file: pid_file_,
          )
        end
        # Add to inittab.
        edit_inittab do |content|
          inittab_line = "#{service_id}:2345:respawn:/sbin/poise_service_#{new_resource.service_name}"
          if content =~ /^# #{Regexp.escape(service_tag)}$/
            # Existing line, update in place.
            content.gsub!(/^(# #{Regexp.escape(service_tag)}\n)(.*)$/, "\\1#{inittab_line}")
          else
            # Add to the end.
            content << "# #{service_tag}\n#{inittab_line}\n"
          end
        end
      end

      def destroy_service
        # Remove from inittab.
        edit_inittab do |content|
          content.gsub!(/^# #{Regexp.escape(service_tag)}\n.*?\n$/, '')
        end

        file "/sbin/poise_service_#{new_resource.service_name}" do
          action :delete
        end

        file pid_file do
          action :delete
        end
      end

      # The shortened ID because sysvinit only allows 4 characters.
      def service_id
        # This is a terrible hash, but it should be good enough.
        options['service_id'] || begin
          sum = new_resource.service_name.sum(20).to_s(36)
          if sum.length < 4
            'p' + sum
          else
            sum
          end
        end
      end

      # Tag to put in a comment in inittab for tracking.
      def service_tag
        "poise_service(#{new_resource.service_name})"
      end

      def pid_file
        options['pid_file'] || "/var/run/#{new_resource.service_name}.pid"
      end

      def edit_inittab(&block)
        inittab = IO.read('/etc/inittab')
        original_inittab = inittab.dup
        block.call(inittab)
        if inittab != original_inittab
          file '/etc/inittab' do
            content inittab
          end

          execute 'telinit q'
        end
      end
    end
  end
end
