Feature: Manage ALM Database
  I should be able to manage ALM content via the command line
  
    @not-teamcity
    Scenario: Articles are added succesfully
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 0 articles, ignored 1 other existing articles"
    
    @not-teamcity
    Scenario: Articles withput publication date are not added
      When I run `bundle exec rake db:articles:load` interactively
      And I pipe in the file "../../spec/fixtures/articles_nil_dates.txt"
      Then the stderr should contain "invalid date"
    
    @not-teamcity
    Scenario: Articles are seeded succesfully
      When I run `bundle exec rake db:articles:seed` interactively
      Then the output should contain "Seeded 25 articles"
    
    @not-teamcity
    Scenario: Articles are deleted succesfully
      When I run `bundle exec rake db:articles:delete` interactively
      Then the output should contain "Deleted 26 articles, 0 articles remaining"
    
    @not-teamcity @announce
    Scenario: Error messages are deleted succesfully
      Given we have 3 resolved error messages
      When I run `bundle exec rake db:error_messages:delete` interactively
      Then the output should contain "Deleted 3 resolved error messages, 0 unresolved errors remaining"
    
    @not-teamcity @announce
    Scenario: API requests are deleted succesfully
      Given we have 10005 API requests
      When I run `bundle exec rake db:api_requests:delete` interactively
      Then the output should contain "Deleted 5 API requests, 10000 API requests remaining"