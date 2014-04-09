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

# TODO this should be part of our private code repository only
# TODO for the open source version, these methods should be blank

class PrivateSourceFilter

  def self.filter(controller)
    if self.filter_private_sources?(controller.env, controller.params)
      Rails.logger.debug "before filtering out private sources: #{controller.params[:source]}"
      controller.params[:source] = self.remove_private_sources(controller.params)
      Rails.logger.debug "after filtering out private sources: #{controller.params[:source]}"
    end
  end

  private

  def self.filter_private_sources?(env, params)
    # the controllers we are interested in are articles and groups
    if not ((params[:controller] == "articles" || params[:controller] == "groups") &&
        env["REQUEST_METHOD"].upcase == "GET")
      return false
    end

    domain = env["HTTP_REFERER"]

    domains = [ "plosone.org", "plosbiology.org", "plosmedicine.org" , "ploscompbiol.org", "plosgenetics.org",
                "plospathogens.org", "plosntds.org", "ploscollections.org", "hubs.plos.org", "clinicaltrials.ploshubs.org",
                "currents.plos.org" ]

    domains = domains + [ "plosone-stage.plos.org", "plosbiology-stage.plos.org", "plosmedicine-stage.plos.org" ,
                          "ploscompbiol-stage.plos.org", "plosgenetics-stage.plos.org","plospathogens-stage.plos.org",
                          "plosntds-stage.plos.org", "ploscollections-stage.plos.org", "hubs-stage.plos.org",
                          "clinicaltrials-stage.plos.org","currents-stage.plos.org" ]

    domains = domains + [ "plosone-dev.plos.org", "plosbiology-dev.plos.org", "plosmedicine-dev.plos.org" ,
                          "ploscompbiol-dev.plos.org", "plosgenetics-dev.plos.org","plospathogens-dev.plos.org",
                          "plosntds-dev.plos.org", "ploscollections-dev.plos.org", "hubs-dev.plos.org",
                          "clinicaltrials-dev.plos.org","currents-dev.plos.org" ]

    domains.each { |d|
      #^http:\/\/(www.|)plospathogens.org.*
      regex = Regexp.new("^http:\/\/(www.|)" + d + ".*")
      if(regex.match(domain))
        return false
      end
    }
    true
  end

  def self.remove_private_sources(params)
    param_sources = params[:source]

    if (param_sources.nil?)
      # if source isn't passed in, get the list of sources without Web of Science
      public_sources = Source.public_sources
      new_param_sources = []
      public_sources.each { |source| new_param_sources << source.name }
      new_param_sources.join(",")
    else
      new_param_sources = param_sources.downcase.split(',')
      private_sources = Source.private_sources
      private_sources.each { |source| new_param_sources.delete(source.name) }
      new_param_sources.join(",")
    end
  end
end