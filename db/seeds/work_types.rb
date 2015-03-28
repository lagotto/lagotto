# Load resource_types
# From CSL: https://github.com/citation-style-language/schema/blob/master/csl-data.json
article = WorkType.where(name: 'article').first_or_create(
  title: 'Article')
article_journal = WorkType.where(name: 'article-journal').first_or_create(
  title: 'Journal Article', container: 'Journal')
article_magazine = WorkType.where(name: 'article-magazine').first_or_create(
  title: 'Magazine Article', container: 'Magazine')
article_newspaper = WorkType.where(name: 'article-newspaper').first_or_create(
  title: 'Newspaper Article', container: 'Newspaper')
bill = WorkType.where(name: 'bill').first_or_create(
  title: 'Bill')
book = WorkType.where(name: 'book').first_or_create(
  title: 'Book')
broadcast = WorkType.where(name: 'broadcast').first_or_create(
  title: 'Broadcast')
chapter = WorkType.where(name: 'chapter').first_or_create(
  title: 'Chapter', container: 'Book')
dataset = WorkType.where(name: 'dataset').first_or_create(
  title: 'Dataset')
entry = WorkType.where(name: 'entry').first_or_create(
  title: 'Entry')
entry_dictionary = WorkType.where(name: 'entry-dictionary').first_or_create(
  title: 'Dictionary Entry', container: 'Dictionary')
entry_encyclopedia = WorkType.where(name: 'entry-encyclopedia').first_or_create(
  title: 'Encyclopedia Entry', container: 'Encyclopedia')
figure = WorkType.where(name: 'figure').first_or_create(
  title: 'Figure')
graphic = WorkType.where(name: 'graphic').first_or_create(
  title: 'Graphic')
interview = WorkType.where(name: 'interview').first_or_create(
  title: 'Interview')
legal_case = WorkType.where(name: 'legal_case').first_or_create(
  title: 'Legal Case')
legislation = WorkType.where(name: 'legislation').first_or_create(
  title: 'Legislation')
manuscript = WorkType.where(name: 'manuscript').first_or_create(
  title: 'Manuscript')
map = WorkType.where(name: 'map').first_or_create(
  title: 'Map')
motion_picture = WorkType.where(name: 'motion_picture').first_or_create(
  title: 'Motion Picture')
musical_score = WorkType.where(name: 'musical_score').first_or_create(
  title: 'Musical Score')
pamphlet = WorkType.where(name: 'pamphlet').first_or_create(
  title: 'Pamphlet')
paper_conference = WorkType.where(name: 'paper-conference').first_or_create(
  title: 'Conference Paper', container: 'Conference')
patent = WorkType.where(name: 'patent').first_or_create(
  title: 'Patent')
personal_communication = WorkType.where(name: 'personal_communication').first_or_create(
  title: 'Personal Communication')
post = WorkType.where(name: 'post').first_or_create(
  title: 'Post')
post_weblog = WorkType.where(name: 'post-weblog').first_or_create(
  title: 'Blog Post', container: 'Blog')
report = WorkType.where(name: 'report').first_or_create(
  title: 'Report')
review = WorkType.where(name: 'review').first_or_create(
  title: 'Review')
review_book = WorkType.where(name: 'review-book').first_or_create(
  title: 'Book Review')
song = WorkType.where(name: 'song').first_or_create(
  title: 'Song')
speech = WorkType.where(name: 'speech').first_or_create(
  title: 'Speech')
thesis = WorkType.where(name: 'thesis').first_or_create(
  title: 'Thesis')
treaty = WorkType.where(name: 'treaty').first_or_create(
  title: 'Treaty')
webpage = WorkType.where(name: 'webpage').first_or_create(
  title: 'Webpage', container: 'Website')
