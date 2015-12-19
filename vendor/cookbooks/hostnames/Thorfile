# -*- ruby -*-

require 'rubygems'
require 'bundler/setup'

require 'shellwords'

class Cookbook < Thor
  COOKBOOK_NAME = 'hostnames'
  COOKBOOK_CATEGORY = 'utilities'

  include Thor::Actions

  desc :edit, "Edit cookbook in browser"
  def edit
    open "http://community.opscode.com/cookbooks/#{COOKBOOK_NAME}/edit"
  end

  desc :browse, "Go to cookbook's page on Opscode's community website"
  def browse
    open "http://community.opscode.com/cookbooks/#{COOKBOOK_NAME}/"
  end

  desc :upload, "Upload cookbook to Opscode's community website"
  def upload
    run "knife cookbook site share #{COOKBOOK_NAME} #{Shellwords.escape(COOKBOOK_CATEGORY)} -o #{Shellwords.escape(File.dirname(File.dirname(__FILE__)))}"
  end

  private

  def open(what)
    run "#{open_cmd} #{Shellwords.escape(what)}"
  end

  def open_cmd
    @open_cmd ||= %w[open xdg-open].find do |command|
      system "which #{command} >/dev/null 2>&1"
      $?.success?
    end
  end
end
