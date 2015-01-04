# Load filters

obsolete_filters = Filter.where(name: 'ArticleNotUpdatedError').delete_all

work_not_updated_error = WorkNotUpdatedError.where(name: 'WorkNotUpdatedError').first_or_create(
  :display_name => 'work not updated error',
  :description => 'Raises an error if articles have not been updated within the specified interval in days.')
event_count_decreasing_error = EventCountDecreasingError.where(name: 'EventCountDecreasingError').first_or_create(
  :display_name => 'decreasing event count error',
  :description => 'Raises an error if event count decreases.')
event_count_increasing_too_fast_error = EventCountIncreasingTooFastError.where(name: 'EventCountIncreasingTooFastError').first_or_create(
  :display_name => 'increasing event count error',
  :description => 'Raises an error if the event count increases faster than the specified value per day.')
api_response_too_slow_error = ApiResponseTooSlowError.where(name: 'ApiResponseTooSlowError').first_or_create(
  :display_name => 'API too slow error',
  :description => 'Raises an error if an API response takes longer than the specified interval in seconds.')
source_not_updated_error = SourceNotUpdatedError.where(name: 'SourceNotUpdatedError').first_or_create(
  :display_name => 'source not updated error',
  :description => 'Raises an error if a source has not been updated in 24 hours.')
citation_milestone_alert = CitationMilestoneAlert.where(name: 'CitationMilestoneAlert').first_or_create(
  :display_name => 'citation milestone alert',
  :description => 'Creates an alert if an work has been cited the specified number of times.')
html_ratio_too_high_error= HtmlRatioTooHighError.where(name: 'HtmlRatioTooHighError').first_or_create(
  :display_name => 'HTML ratio too high error',
  :description => 'Raises an error if HTML/PDF ratio is higher than 50.')
