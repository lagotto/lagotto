#
# Cookbook Name:: libarchive
# Library:: helper
#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
#

module LibArchiveCookbook
  module Helper
    class << self
      # This can't be a constant since we might not have required 'archive' yet
      def extract_option_map
        {
          owner: ::Archive::EXTRACT_OWNER,
          permissions: ::Archive::EXTRACT_PERM,
          time: ::Archive::EXTRACT_TIME,
          no_overwrite: ::Archive::EXTRACT_NO_OVERWRITE,
          acl: ::Archive::EXTRACT_ACL,
          fflags: ::Archive::EXTRACT_FFLAGS,
          extended_information: ::Archive::EXTRACT_XATTR,
          xattr: ::Archive::EXTRACT_XATTR,
        }
      end

      # @param [String] src
      # @param [String] dest
      # @param [Array] extract_options
      #
      # @return [Boolean]
      def extract(src, dest, extract_options = [])
        require 'archive'

        extract_options ||= Array.new
        extract_options.collect! { |option| extract_option_map[option] }.compact!

        Dir.chdir(dest) do
          archive       = ::Archive.new(src)
          archive_files = archive.map { |entry| entry.path }

          existing, missing = archive_files.partition { |f| File.exist?(File.join(dest, f)) }
          current_times     = existing.reduce({}) { |times, f| times[f] = File.mtime(f); times }

          archive.extract(extract: extract_options.reduce(:|))

          unless missing.empty?
            # are all files which were missing no longer missing?
            still_missing = missing.reject { |f| File.exist?(f) }
            return true if still_missing.length < missing.length
          end

          # any existing files have their mtimes changed?
          changed_files = current_times.select { |file, time| File.mtime(file) != time }
          return true unless changed_files.empty?
        end

        false
      end
    end
  end
end
