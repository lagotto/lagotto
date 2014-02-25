Feature: Manage ALM Database
  I should be able to manage ALM content via the command line

    Scenario: Articles are added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 1 articles, ignored 0 existing articles"

    @not_teamcity
    Scenario: Articles with year and month as publication date added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_year_month.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 1 articles, ignored 0 existing articles"

    @not_teamcity
    Scenario: Articles with year as publication date added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_year.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 1 articles, ignored 0 existing articles"

    Scenario: Articles without publication date are not added
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_nil_dates.txt"
      Then the stderr should contain "Validation failed: Year is not a number"

    Scenario: Articles are deleted succesfully
      When I run `bundle exec rake db:articles:delete` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Deleted 1 articles, ignored 1 articles"