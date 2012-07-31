# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2012 by Public Library of Science, a non-profit corporation
# http://www.plos.org/
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
