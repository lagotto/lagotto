# Feature: Import PMC data
#   I should be able to import PMC data
#   
#   Scenario: Import PMC data
#     When I run `bundle exec rake pmc:update[1,2013]` interactively
#     Then the output should contain "Getting PMC information for 1 2013"
#     And the output should contain "Filepath: /home/alm/pmcdata/"
#     And the output should contain "Service URL: http://rwc-couch01.int.plos.org:5984/pmc_usage_stats/%{doi}"
#     And the exit status should be 0