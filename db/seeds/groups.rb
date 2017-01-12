# Load groups
cited       = Group.where(name: 'cited').first_or_create(title: 'Cited')
discussed   = Group.where(name: 'discussed').first_or_create(title: 'Discussed')
other       = Group.where(name: 'other').first_or_create(title: 'Other')
recommended = Group.where(name: 'recommended').first_or_create(title: 'Recommended')
saved       = Group.where(name: 'saved').first_or_create(title: 'Saved')
viewed      = Group.where(name: 'viewed').first_or_create(title: 'Viewed')
