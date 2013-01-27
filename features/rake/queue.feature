# Feature: Queue articles
#   I should be able to queue articles for jobs
#   
#   Background:
#     Given the source "Citeulike" exists
#   
#     Scenario: Start queue for specific source
#       When I run `bundle exec rake queue:one[citeulike,verbose]`
#       Then the output should contain "Now sleeping" 
#     
#     Scenario: Start queue for all sources
#       When I run `bundle exec rake queue:all[verbose]`
#       Then the output should contain "Now sleeping" 