# encoding: UTF-8

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

require 'spec_helper'

describe Worker do

  context "class methods" do
    subject { Worker }

    it { should respond_to :all }
    it { should respond_to :find }
    it { should respond_to :count }
    it { should respond_to :start }
    it { should respond_to :stop }
    it { should respond_to :monitor }
  end

  context "instance methods" do

    before(:all) do
      Worker.start
    end

    after(:all) do
      Worker.stop
    end

    subject { Worker.all[0] }

    its(:id) { should_not be_nil }
    its(:pid) { should_not be_nil }
    its(:state) { should eq("S (sleeping)") }
    its(:memory) { should_not be_nil }
    its(:created_at) { should_not be_nil }
  end

end
