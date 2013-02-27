Feature: Import Articles
  I should be able to import articles
  
    Scenario: Articles are added succesfully
      When I run `rake doi_import` interactively
      And I pipe in the file "../../spec/fixtures/articles.txt"
      Then the output should contain "Reading DOIs from standard input..."
      Then the output should contain "Read 2 valid entries; ignored 0 invalid entries"
      Then the output should contain "Saved 1 new articles, updated 0 articles, ignored 1 other existing articles"
      
    Scenario: Articles withput publication date are not added
      When I run `rake doi_import` interactively
      And I pipe in the file "../../spec/fixtures/articles_nil_dates.txt"
      Then the stderr should contain "invalid date"

