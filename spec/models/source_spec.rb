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
  it { should validate_numericality_of(:workers).only_integer.with_message("should be between 1 and 20") }
  it { should ensure_inclusion_of(:workers).in_range(1..20).with_message("should be between 1 and 20") }
  it { should validate_numericality_of(:timeout).only_integer.with_message("should be between 1 and 3600") }
  it { should ensure_inclusion_of(:timeout).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_numericality_of(:wait_time).only_integer.with_message("should be between 1 and 3600") }
  it { should ensure_inclusion_of(:wait_time).in_range(1..3600).with_message("should be between 1 and 3600") }
  it { should validate_numericality_of(:max_failed_queries).only_integer.with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:max_failed_queries).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should validate_numericality_of(:max_failed_query_time_interval).only_integer.with_message("should be between 1 and 864000") }
  it { should ensure_inclusion_of(:max_failed_query_time_interval).in_range(1..864000).with_message("should be between 1 and 864000") }
  it { should validate_numericality_of(:job_batch_size).only_integer.with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:job_batch_size).in_range(1..1000).with_message("should be between 1 and 1000") }
  it { should ensure_inclusion_of(:rate_limiting).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_week).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_week).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_month).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_month).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_year).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_year).in_range(1..2678400).with_message("should be between 1 and 2678400") }
  it { should validate_numericality_of(:staleness_all).with_message("should be between 1 and 2678400") }
  it { should ensure_inclusion_of(:staleness_all).in_range(1..2678400).with_message("should be between 1 and 2678400") }

end
