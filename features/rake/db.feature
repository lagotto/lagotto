Feature: Manage ALM Database
  I should be able to manage ALM content via the command line

    @not_teamcity
    Scenario: Articles are added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 0 articles, ignored 1 existing articles"

    @not_teamcity
    Scenario: Articles withput publication date are not added
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_nil_dates.txt"
      Then the stderr should contain "invalid date"

    @not_teamcity
    Scenario: Articles are deleted succesfully
      When I run `bundle exec rake db:articles:delete` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Deleted 1 articles, ignored 1 articles"