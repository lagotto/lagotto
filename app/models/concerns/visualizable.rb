# encoding: UTF-8

# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2014 by Public Library of Science, a non-profit corporation
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

module Visualizable
  extend ActiveSupport::Concern

  included do

    def by_day
      return nil if events.blank?

      case name
      when "citeulike"
        events_30 = events.select { |event| event["event"]["post_time"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["post_time"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length } }
      when "researchblogging"
        events_30 = events.select { |event| event["event"]["published_date"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["published_date"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "scienceseeker"
        events_30 = events.select { |event| event["event"]["updated"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["updated"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "wordpress"
        events_30 = events.select { |event| Time.at(event["event"]["epoch_time"].to_i).to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "openedition"
        events_30 = events.select { |event| Time.at(event["event"]["epoch_time"].to_i).to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["date"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "twitter"
        events_30 = events.select { |event| event["event"]["created_at"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "twitter_search"
        events_30 = events.select { |event| event["event"]["created_at"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "articlecoveragecurated"
        events_30 = events.select { |event| event["event"]["published_on"].to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["published_on"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "reddit"
        events_30 = events.select { |event| Time.at(event["event"]["created_utc"]).to_date - article.published_on < 30 }
        return nil if events_30.blank?
        events_30.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      # when "plos_comments"
      #   events_30 = events.select { |event| event["event"]["created"].to_date - article.published_on < 30 }
      #   return nil if events_30.blank?
      #   events_30.group_by { |event| event["event"]["created"].to_datetime.strftime("%Y-%m-%d") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :day => k[8..9].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      else
        # crossref, facebook, mendeley, pubmed, nature, scienceseeker, copernicus, wikipedia
        nil
      end
    end

    def by_month
      return nil if events.blank?

      case name
      when "counter"
        events.map { |event| { :year => event["year"].to_i, :month => event["month"].to_i, :pdf => event["pdf_views"].to_i, :html => event["html_views"].to_i, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event["pdf_views"].to_i + event["html_views"].to_i } }
      when "pmc"
        events.map { |event| { :year => event["year"].to_i, :month => event["month"].to_i, :pdf => event["pdf"].to_i, :html => event["full-text"].to_i, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => event["pdf"].to_i + event["full-text"].to_i } }
      when "citeulike"
        events.group_by { |event| event["event"]["post_time"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length } }
      when "twitter"
        events.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "twitter_search"
        events.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "articlecoveragecurated"
        events.group_by { |event| event["event"]["published_on"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "reddit"
        events.group_by { |event| Time.at(event["event"]["created_utc"]).to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      # when "plos_comments"
      #     events.group_by { |event| event["event"]["created_at"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "researchblogging"
        events.group_by { |event| event["event"]["published_date"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "scienceseeker"
        events.group_by { |event| event["event"]["updated"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "wordpress"
        events.group_by { |event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "openedition"
        events.group_by { |event| event["event"]["date"].to_datetime.strftime("%Y-%m") }.sort.map { |k, v| { :year => k[0..3].to_i, :month => k[5..6].to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      else
      # crossref, facebook, mendeley, pubmed, nature, copernicus, wikipedia
        nil
      end
    end

    def by_year
      return nil if events.blank?

      case name
      when "counter"
        events.group_by { |event| event["year"] }.sort.map { |k, v| { :year => k.to_i, :pdf => v.inject(0) { |sum, hash| sum + hash["pdf_views"].to_i }, :html => v.inject(0) { |sum, hash| sum + hash["html_views"].to_i }, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.inject(0) { |sum, hash| sum + hash["html_views"].to_i + hash["pdf_views"].to_i + hash["xml_views"].to_i } } }
      when "pmc"
        events.group_by { |event| event["year"] }.sort.map { |k, v| { :year => k.to_i, :pdf => v.inject(0) { |sum, hash| sum + hash["pdf"].to_i }, :html => v.inject(0) { |sum, hash| sum + hash["full-text"].to_i }, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.inject(0) { |sum, hash| sum + hash["full-text"].to_i + hash["pdf"].to_i } } }
      when "citeulike"
        events.group_by { |event| event["event"]["post_time"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => v.length, :groups => nil, :comments => nil, :likes => nil, :citations => nil, :total => v.length } }
      when "crossref"
        events.group_by { |event| event["event"]["year"] }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "twitter"
        events.group_by { |event| event["event"]["created_at"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "twitter_search"
        events.group_by { |event| event["event"]["created_at"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      # when "plos_comments"
        #   events.group_by { |event| event["event"]["created_at"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "articlecoveragecurated"
        events.group_by { |event| event["event"]["published_on"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "reddit"
        events.group_by { |event| Time.at(event["event"]["created_utc"]).to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => v.length, :likes => nil, :citations => nil, :total => v.length } }
      when "researchblogging"
        events.group_by { |event| event["event"]["published_date"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "scienceseeker"
        events.group_by { |event| event["event"]["updated"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "wordpress"
        events.group_by { |event| Time.at(event["event"]["epoch_time"].to_i).to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      when "openedition"
        events.group_by { |event| event["event"]["date"].to_datetime.year }.sort.map { |k, v| { :year => k.to_i, :pdf => nil, :html => nil, :shares => nil, :groups => nil, :comments => nil, :likes => nil, :citations => v.length, :total => v.length } }
      else
        # facebook, mendeley, pubmed, nature, copernicus, wikipedia
        nil
      end
    end

  end
end
