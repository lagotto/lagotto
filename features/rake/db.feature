@javascript
Feature: Manage ALM Database
  I should be able to manage ALM content via the command line

  Background:
    Given I am logged in as "admin"

    Scenario: Articles are queued succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Started import of 2 articles in the background..."

    Scenario: Articles are added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      And I go to the "Alerts" page
      Then I should see 0 alert

    Scenario: Articles with year and month as publication date added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_year_month.txt"
      And I go to the "Alerts" page
      Then I should see 0 alert

    Scenario: Articles with year as publication date added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_year.txt"
      And I go to the "Alerts" page
      Then I should see 0 alert

    Scenario: Articles without publication date are not added
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_nil_dates.txt"
      And I go to the "Alerts" page
      Then I should see 0 alert

    Scenario: Articles are deleted succesfully
      When I run `bundle exec rake db:articles:delete` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading dois from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Deleted 0 articles, ignored 2 articles"
