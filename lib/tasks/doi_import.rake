# $HeadURL: https://mfenner@developer.plos.org/svn/plos/plos-alm/branches/alm-queue/lib/tasks/doi_import.rake $
# $Id: doi_import.rake 10938 2012-08-03 02:09:35Z jsong $
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

desc "Bulk-import DOIs from standard input"
task :doi_import => :environment do
  puts "Reading DOIs from standard input..."
  valid = []
  invalid = []
  duplicate = []
  created = []
  updated = []

  while (line = STDIN.gets)
    line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
    raw_doi, raw_published_on, raw_title = line.strip.split(" ", 3)

    doi = Article.from_uri(raw_doi.strip).values.first
    published_on = Date.parse(raw_published_on.strip) if raw_published_on
    title = raw_title.strip if raw_title
    if (doi =~ DOI_FORMAT) and !published_on.nil? and !title.nil?
      valid << [doi, published_on, title]
    else
      puts "Ignoring DOI: #{raw_doi}, #{raw_published_on}, #{raw_title}"
      invalid << [raw_doi, raw_published_on, raw_title]
    end
  end

  puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries"

  if valid.size > 0
    valid.each do |doi, published_on, title|
      existing = Article.find_by_doi(doi)
      unless existing
        article = Article.create(:doi => doi, :published_on => published_on,
                                 :title => title)
        created << doi
      else
        if existing.published_on != published_on or existing.title != title
          existing.published_on = published_on
          existing.title = title
          existing.save!
          updated << doi
        else
          duplicate << doi
        end
      end
    end
  end

  puts "Saved #{created.size} new articles, updated #{updated.size} articles, ignored #{duplicate.size} other existing articles"
end

# This should be used only when you are trying to sync up articles in alm with articles in ambra database
task :cleanup_plos_articles => :environment do
  puts "Reading DOIs from standard input..."
  valid = []
  invalid = []

  while (line = STDIN.gets)
    line = ActiveSupport::Multibyte::Unicode.tidy_bytes(line)
    raw_doi, raw_published_on, raw_title = line.strip.split(" ", 3)

    doi = Article.from_uri(raw_doi.strip).values.first
    published_on = Date.parse(raw_published_on.strip) if raw_published_on
    title = raw_title.strip if raw_title
    if (doi =~ DOI_FORMAT) and !published_on.nil? and !title.nil?
      valid << doi
    else
      puts "Ignoring DOI: #{raw_doi}, #{raw_published_on}, #{raw_title}"
      invalid << raw_doi
    end
  end

  puts "Read #{valid.size} valid entries; ignored #{invalid.size} invalid entries;"

  articles_from_alm = Article.where("doi like '10.1371/journal.p%'").pluck(:doi)

  # get articles that are in alm but not in ambra
  bad_articles = articles_from_alm - valid

  bad_articles.each do | doi |
    article = Article.find_by_doi(doi)
    puts "deleting article #{article.doi}, #{article.title}, #{article.published_on}"
    Article.destroy(article.id)
  end

  puts "Deleted #{bad_articles.size} articles"
end
