
namespace :wsdl do
  desc "Update our code generated from Scopus' WSDL"
  task :scopus => :environment do
    scopus_dir = File.join(Rails.root, "app/models/sources/scopus")

    puts "Removing old generated Scopus files"
    `rm -f #{scopus_dir}/*.rb`

    live_mode = ENV["LIVE"] == "1"
    scopus_url = Scopus.wsdl_url(live_mode)

    puts "Regenerating code from Scopus' #{live_mode ? 'live' : 'test'}-mode WSDL (ignore ignored elements!)"

    `wsdl2ruby.rb --wsdl #{scopus_url} --classdef --mapping_registry --driver --quiet`
  end
end
