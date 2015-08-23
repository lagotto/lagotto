#
# Cookbook: libartifact-cookbook
# License: Apache 2.0
#
# Copyright (C) 2015 Bloomberg Finance L.P.
#
require 'poise'

module LibArtifactCookbook
  module Resource
    # Resource for a release artifact on the system.
    # @since 1.0.0
    class ArtifactFile < Chef::Resource
      include Poise(fused: true)
      provides(:libartifact_file)
      default_action(:create)

      attribute(:artifact_name, kind_of: String, name_attribute: true)
      attribute(:artifact_version, kind_of: String, required: true)
      attribute(:install_path, kind_of: String, default: '/srv')

      attribute(:remote_url, kind_of: [Array, String], required: true)
      attribute(:remote_checksum, kind_of: String)
      attribute(:owner, kind_of: String)
      attribute(:group, kind_of: String)
      attribute(:symlink_path, kind_of: String, default: lazy { current_path })
      attribute(:extract_options, kind_of: [Array, Symbol], default: :no_overwrite)

      # The absolute path to the artifact's release directory.
      # @return [String]
      def release_path
        ::File.join(install_path, artifact_name, artifact_version)
      end

      # The absolute path to the current symlink for this artifact.
      # @return [String]
      def current_path
        ::File.join(install_path, artifact_name, 'current')
      end

      # Retrieves the +remote_file+, unpacks it and creates a symlink to
      # +symlink_path+.
      action(:create) do
        notifying_block do
          include_recipe 'libarchive::default'

          extension = ::File.extname(new_resource.remote_url)
          friendly_name = "#{new_resource.artifact_name}-#{new_resource.artifact_version}#{extension}"

          directory ::File.join(new_resource.install_path, new_resource.artifact_name) do
            owner new_resource.owner
            group new_resource.group
            mode '0755'
          end

          archive = remote_file new_resource.remote_url do
            path ::File.join(Chef::Config[:file_cache_path], friendly_name)
            source new_resource.remote_url
            checksum new_resource.remote_checksum
            action :create_if_missing
          end

          libarchive_file archive.path do
            extract_to new_resource.release_path
            extract_options new_resource.extract_options
            owner new_resource.owner
            group new_resource.group
          end

          link new_resource.symlink_path do
            to new_resource.release_path
            only_if { new_resource.symlink_path }
          end
        end
      end

      # Removes +symlink_path+ and deletes the +release_path+.
      action(:delete) do
        notifying_block do
          link new_resource.symlink_path do
            to new_resource.release_path
            action :delete
            only_if { new_resource.symlink_path }
          end

          directory new_resource.release_path do
            recursive true
            action :delete
          end
        end
      end
    end
  end
end
