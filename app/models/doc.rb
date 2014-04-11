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

class Doc

  attr_reader :title, :content

  def self.all
    Dir.entries(Rails.root.join("docs"))
  end

  def self.find(param)
    name = all.detect { |doc| doc.downcase == "#{param.downcase}.md" }
    if name.present?
      self.new(name)
    else
      OpenStruct.new({ title: "No title", content: "" })
    end
  end

  def initialize(name)
    file = IO.read(Rails.root.join("docs/#{name}"))

    if (md = file.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
      content = md.post_match
      metadata = YAML.load(md[:metadata])
      title = metadata["title"]
    end

    @content = content || ""
    @title = title || "No title"
  end
end