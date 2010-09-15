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

def determine_revision
  # Note the revision we're running
  revisionFile = Rails.root + "/REVISION"
  digits = 8
  Rails.env + begin
    " " + File.read(revisionFile).strip[0...digits]
  rescue
    begin
      if File.exist?(".git")
        " #{`git log -1`.split(" ")[1][0...digits]} #{`git branch`.split("\n")[0].split(" ")[-1]}"
      else
        " " + `svn info`.grep(%r"^Revision: ")[0].split(" ")[1]
      end
    rescue
      ""
    end
  end
end 
SOURCE_REVISION = determine_revision
