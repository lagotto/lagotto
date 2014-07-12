Feature: Manage ALM Database
  I should be able to manage ALM content via the command line

    Scenario: Articles are added
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Started import of 2 articles in the background..."

    @not_teamcity
    Scenario: Articles are deleted succesfully
      When I run `bundle exec rake db:articles:delete` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Deleted 1 articles, ignored 1 articles"
