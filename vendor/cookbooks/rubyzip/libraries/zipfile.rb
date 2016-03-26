#
# Cookbook: rubyzip
# License: Apache 2.0
#
# Copyright 2010, VMware, Inc.
# Copyright 2011-2015, Chef Software, Inc.
# Copyright 2016, Bloomberg Finance L.P.
#
require 'find'
require 'poise'

module RubyzipCookbook
  module Resource
    class Zipfile < Chef::Resource
      include Poise(fused: true)
      provides(:zipfile)

      property :path, kind_of: String, name_attribute: true
      property :files_owner, kind_of: String
      property :files_group, kind_of: String
      property :overwrite, equal_to: [true, false], default: false
      property :source, kind_of: String
      property :checksum, kind_of: String

      action :unzip do
        filename = ::File.join(Chef::Config[:file_cache_path], ::File.basename(new_resource.source))
        notifying_block do
          run_context.include_recipe 'rubyzip::default'

          remote_file filename do
            source URI.parse(new_resource.source).to_s
            backup false
            checksum new_resource.checksum
            only_if { new_resource.source =~ %r{^(file|ftp|http|https):\/\/} }
            action :nothing
          end.run_action(:create_if_missing)
        end

        filename.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if node.platform?('windows')

        Zip::File.open(filename) do |zip|
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
        notifying_block { run_context.include_recipe 'rubyzip::default' }

        if new_resource.overwrite == false && ::File.exist?(new_resource.path)
          Chef::Log.info("file #{new_resource.path} already exists and overwrite is set to false, exiting")
        else
          ::File.unlink(new_resource.path) if ::File.exist?(new_resource.path)
          if ::File.directory?(new_resource.source)
            z = Zip::File.new(new_resource.path, true)
            unless new_resource.source =~ /::File::ALT_SEPARATOR$/
              new_resource.source << ::File::ALT_SEPARATOR
            end
            Find.find(new_resource.source) do |f|
              f.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
              next if f == new_resource.source
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
    end
  end
end
