# Load resource_types
# From CSL: https://github.com/citation-style-language/schema/blob/master/csl-data.json
article = WorkType.where(name: 'article').first_or_create
article_journal = WorkType.where(name: 'article-journal').first_or_create
article_magazine = WorkType.where(name: 'article-magazine').first_or_create
article_newspaper = WorkType.where(name: 'article-newspaper').first_or_create
bill = WorkType.where(name: 'bill').first_or_create
book = WorkType.where(name: 'book').first_or_create
broadcast = WorkType.where(name: 'broadcast').first_or_create
chapter = WorkType.where(name: 'chapter').first_or_create
dataset = WorkType.where(name: 'dataset').first_or_create
entry = WorkType.where(name: 'entry').first_or_create
entry_dictionary = WorkType.where(name: 'entry-dictionary').first_or_create
entry_encyclopedia = WorkType.where(name: 'entry-encyclopedia').first_or_create
figure = WorkType.where(name: 'figure').first_or_create
graphic = WorkType.where(name: 'graphic').first_or_create
interview = WorkType.where(name: 'interview').first_or_create
legal_case = WorkType.where(name: 'legal_case').first_or_create
legislation = WorkType.where(name: 'legislation').first_or_create
manuscript = WorkType.where(name: 'manuscript').first_or_create
map = WorkType.where(name: 'map').first_or_create
motion_picture = WorkType.where(name: 'motion_picture').first_or_create
musical_score = WorkType.where(name: 'musical_score').first_or_create
pamphlet = WorkType.where(name: 'pamphlet').first_or_create
paper_conference = WorkType.where(name: 'paper-conference').first_or_create
patent = WorkType.where(name: 'patent').first_or_create
personal_communication = WorkType.where(name: 'personal_communication').first_or_create
post = WorkType.where(name: 'post').first_or_create
post_weblog = WorkType.where(name: 'post-weblog').first_or_create
report = WorkType.where(name: 'report').first_or_create
review = WorkType.where(name: 'review').first_or_create
review_book = WorkType.where(name: 'review-book').first_or_create
song = WorkType.where(name: 'song').first_or_create
speech = WorkType.where(name: 'speech').first_or_create
thesis = WorkType.where(name: 'thesis').first_or_create
treaty = WorkType.where(name: 'treaty').first_or_create
webpage = WorkType.where(name: 'webpage').first_or_create
