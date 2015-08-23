#
# Cookbook Name:: libarchive
# Library:: helper
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

module LibArchiveCookbook
  module Helper
    class << self
      # This can't be a constant since we might not have required 'ffi-libarchive' yet.
      def extract_option_map
        {
          owner: Archive::EXTRACT_OWNER,
          permissions: Archive::EXTRACT_PERM,
          time: Archive::EXTRACT_TIME,
          no_overwrite: Archive::EXTRACT_NO_OVERWRITE,
          acl: Archive::EXTRACT_ACL,
          fflags: Archive::EXTRACT_FFLAGS,
          extended_information: Archive::EXTRACT_XATTR,
          xattr: Archive::EXTRACT_XATTR,
        }
      end

      # @param [String] src
      # @param [String] dest
      # @param [Array] options
      #
      # @return [Boolean]
      def extract(src, dest, options = [])
        require 'ffi-libarchive'

        flags = [options].flatten.map { |option| extract_option_map[option] }.compact.reduce(:|)
        modified = false

        Dir.chdir(dest) do
          archive = Archive::Reader.open_filename(src)

          archive.each_entry do |e|
            pathname = File.expand_path(e.pathname)
            if File.exist?(pathname)
              modified = true unless File.mtime(pathname) == e.mtime
            else
              modified = true
            end

            archive.extract(e, flags.to_i)
          end
        end

        modified
      end
    end
  end
end
