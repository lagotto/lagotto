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

class DocsController < ApplicationController

  respond_to :html

  def show
    # filter query parameters by files in "docs" folder, use "Home" if no match is found
    # we serve images from the docs folder to keep the folder structure consistent with
    # what the Github wiki understands
    files = Dir.entries(Rails.root.join("docs"))
    image = files.detect { |s| s == "#{params[:id]}" }
    if image.present?
      send_file Rails.root.join("docs/#{image}"), type: "image/png", :disposition => 'inline'
    else
      file = files.detect { |s| s == "#{params[:id]}.md" }
      file = "Home.md" if file.nil?
      @doc = { :title => file[0..-4], :text => IO.read(Rails.root.join("docs/#{file}")) }
    end
  end

  def index
    redirect_to "/docs/Home"
  end
end