namespace :wsdl do
  desc "Update our code generated from Scopus' WSDL"
  task :scopus => :environment do
    scopus_dir = File.join(Rails.root, "app/models/sources/scopus")

    puts "Retrieving Scopus' WSDL URL from database"
    scopus_url = Source.find_by_type("Scopus").url rescue nil
    abort "Scopus source's WSDL URL isn't configured! (#{Rails.env} environment)" unless scopus_url

    puts "Removing old generated Scopus files"
    `rm -f #{scopus_dir}/*.rb`

    puts "Regenerating code from Scopus' WSDL (ignore ignored elements!)"
    wsdl2ruby_dir = $LOAD_PATH.grep(/soap4r/).find {|dir| File.exist?(File.join(dir, "wsdl2ruby.rb")) }
    `cd #{scopus_dir}; (echo 'gem "soap4r"'; cat #{wsdl2ruby_dir}/wsdl2ruby.rb) | ruby -rubygems /dev/stdin --wsdl #{scopus_url} --classdef --mapping_registry --driver --quiet`
    #`cd #{scopus_dir}; ruby #{wsdl2ruby_dir}/wsdl2ruby.rb --wsdl #{scopus_url} --classdef --mapping_registry --driver --quiet`
  end
end
