#
# Cookbook: rubyzip
# License: Apache 2.0
#
# Copyright 2010, VMware, Inc.
# Copyright 2011-2015, Chef Software, Inc.
# Copyright 2016, Bloomberg Finance L.P.
#
module RubyzipCookbook
  class Rubyzip < ChefCompat::Resource
    require 'find'

    resource_name :zipfile
    property :path, String, name_property: true
    property :files_owner, String
    property :files_group, String
    property :source, String
    property :overwrite, [TrueClass, FalseClass], default: false
    property :checksum, String

    action :unzip do
      run_context.include_recipe 'rubyzip::default'

      Chef::Log.debug("unzip #{new_resource.source} => #{new_resource.path} (overwrite=#{new_resource.overwrite})")

      Zip::File.open(new_resource.cached_file) do |zip|
        zip.each do |entry|
          path = ::File.join(new_resource.path, entry.name)
          FileUtils.mkdir_p(::File.dirname(path))
          if new_resource.overwrite && ::File.exist?(path) && !::File.directory?(path)
            FileUtils.rm(path)
          end
          zip.extract(entry, path)
          FileUtils.chown(new_resource.files_owner, new_resource.files_group, path)
        end
      end
      new_resource.updated_by_last_action(true)
    end

    action :zip do
      run_context.include_recipe 'rubyzip::default'

      new_resource.source.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
      new_resource.path.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
      Chef::Log.debug("zip #{new_resource.source} => #{new_resource.path} (overwrite=#{new_resource.overwrite})")

      if new_resource.overwrite == false && ::File.exist?(new_resource.path)
        Chef::Log.info("file #{new_resource.path} already exists and overwrite is set to false, exiting")
      else
        # delete the archive if it already exists, because we are recreating it.
        ::File.unlink(new_resource.path) if ::File.exist?(new_resource.path)
        # only supporting compression of a single directory (recursively).
        if ::File.directory?(new_resource.source)
          z = Zip::File.new(new_resource.path, true)
          unless new_resource.source =~ /::File::ALT_SEPARATOR$/
            new_resource.source << ::File::ALT_SEPARATOR
          end
          Find.find(new_resource.source) do |f|
            f.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
            # don't add root directory to the zipfile.
            next if f == new_resource.source
            # strip the root directory from the filename before adding it to the zipfile.
            zip_fname = f.sub(new_resource.source, '')
            Chef::Log.debug("adding #{zip_fname} to archive, sourcefile is: #{f}")
            z.add(zip_fname, f)
          end
          z.close
          new_resource.updated_by_last_action(true)
        else
          Chef::Log.info("Single directory must be specified for compression, and #{new_resource.source} does not meet that criteria.")
        end
      end
    end

    def cached_file
      @installer_file_path ||=
        begin
          if source =~ /^(file|ftp|http|https):\/\//
            uri = URI.parse(source)
            cache_file_path = "#{Chef::Config[:file_cache_path]}/#{::File.basename(::URI.unescape(uri.path))}"
            Chef::Log.debug("Caching a copy of file #{source} at #{cache_file_path}")
            remote_file cache_file_path do
              source uri.to_s
              backup false
              checksum checksum unless checksum.nil?
            end.run_action(:create)
          else
            cache_file_path = source
          end
          cache_file_path.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if node.platform?('windows')
          cache_file_path
        end
    end
  end
end
