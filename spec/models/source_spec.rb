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

describe Source do

  it { should belong_to(:group) }
  it { should have_many(:retrieval_statuses).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:display_name) }
  it { should validate_numericality_of(:workers).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:timeout).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:wait_time).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:max_failed_queries).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:max_failed_query_time_interval).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:job_batch_size).only_integer.with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:job_batch_size).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should validate_numericality_of(:rate_limiting).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_week).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_month).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_year).is_greater_than(0).only_integer.with_message("must be greater than 0") }
  it { should validate_numericality_of(:staleness_all).is_greater_than(0).only_integer.with_message("must be greater than 0") }

end
