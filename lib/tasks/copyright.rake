# $HeadURL$
# $Id$
#
# Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
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

desc "Generate the copyright message on all the source headers"
task :copyright do
  require 'find'
  header = <<EOS
$HeadURL$
$Id$

Copyright (c) 2009-2010 by Public Library of Science, a non-profit corporation
http://www.plos.org/

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
EOS
  paths = %w( app config/initializers db/migrate lib public/stylesheets
              test/fixtures test/unit test/functional
            ).map { |p| Rails.root + p }
  Find.find *paths do |path|
    next  unless FileTest.file? path

    p path

    File.open path + '.copyright', 'w' do |f|
      ext = File.extname path
      ext = File.basename path if ext.blank?
      comment =
        case ext
        when '.rb', '.rake', '.yml', '.sample', '.example'
          header.gsub(/^/, '# ') + "\n"
        when '.erb'
          "<%#\n" + header.gsub(/^/, '  # ') + "-%>\n"
        when '.haml'
          "-#\n" + header.gsub(/^/, '  # ')
        when '.sass', '.css'
          "/*\n" + header.gsub(/^/, ' * ') + " */\n"
        when '.gif', '.copyright', '.gitignore'
          next
        else
          raise "Unknown file type '#{ext}'"
        end
      f.write comment.gsub(/ +$/, '')

      skipping = true
      File.open path do |src|
        while l = src.gets
          # strip out previous copyright message if it exists
          if skipping
            skipping =
              case ext
              when '.rb', '.rake', '.yml', '.sample', '.example'
                (skipping != '' && l[/^(#( |$)|$)/]) || (skipping == '' && l[/^$/])
              when '.erb'
                l[/^(  #( |$)|<%#|-%>)/]
              when '.haml'
                l[/^(  #( |$)|-#)/]
              when '.sass', '.css'
                l[%r{^( \*( |/$)|/\*)}]
              end
            next if skipping
          end
          f.write l
        end
      end

      FileUtils.mv path + '.copyright', path
    end
  end
end
