# $HeadURL: http://ambraproject.org/svn/plos/alm/head/test/unit/source_test.rb $
# $Id: source_test.rb 5693 2010-12-03 19:09:53Z josowski $
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

require 'test_helper'

class SourceTest < ActiveSupport::TestCase
  def test_should_report_configured_sources
    assert_equal Source.all.to_set,
      [sources(:connotea), sources(:crossref)].to_set
  end

  def test_should_report_unconfigured_subclasses
    assert Source.unconfigured_source_names.include?("Bloglines")
  end

  def test_should_calculate_staleness_limit
    assert_equal Source.maximum_staleness, 1.year
  end

  def test_sources_degrade_on_error
    delay = 4
    s = sources(:connotea)
    s.update_attribute :disable_delay, delay
    assert_nil s.disable_until

    s.expects(:perform_query).raises.then.returns(12345).twice

    assert_raise RuntimeError do
      s.query articles(:stale)
    end
    assert s.disable_until > (delay-1).seconds.from_now
    assert_equal false, s.query(articles(:stale))
    sleep delay
    assert_equal 12345, s.query(articles(:stale))
  end

  def test_source_sends_notification_email_on_long_delay
    s = sources(:connotea)
    s.update_attribute :disable_delay, 2.days
    s.expects(:perform_query).raises.once
    assert_raise RuntimeError do
      s.query articles(:stale)
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_new_source_creates_retrievals_for_all_articles
    s = Source.create
    assert s.valid?
    assert_equal Article.count, s.retrievals.count
  end
end
