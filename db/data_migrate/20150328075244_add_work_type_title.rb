class AddWorkTypeTitle < ActiveRecord::Migration
  def up
    article = WorkType.where(name: 'article').update_all(
      title: 'Article')
    article_journal = WorkType.where(name: 'article-journal').update_all(
      title: 'Journal Article', container: 'Journal')
    article_magazine = WorkType.where(name: 'article-magazine').update_all(
      title: 'Magazine Article', container: 'Magazine')
    article_newspaper = WorkType.where(name: 'article-newspaper').update_all(
      title: 'Newspaper Article', container: 'Newspaper')
    bill = WorkType.where(name: 'bill').update_all(
      title: 'Bill')
    book = WorkType.where(name: 'book').update_all(
      title: 'Book')
    broadcast = WorkType.where(name: 'broadcast').update_all(
      title: 'Broadcast')
    chapter = WorkType.where(name: 'chapter').update_all(
      title: 'Chapter', container: 'Book')
    dataset = WorkType.where(name: 'dataset').update_all(
      title: 'Dataset')
    entry = WorkType.where(name: 'entry').update_all(
      title: 'Entry')
    entry_dictionary = WorkType.where(name: 'entry-dictionary').update_all(
      title: 'Dictionary Entry', container: 'Dictionary')
    entry_encyclopedia = WorkType.where(name: 'entry-encyclopedia').update_all(
      title: 'Encyclopedia Entry', container: 'Encyclopedia')
    figure = WorkType.where(name: 'figure').update_all(
      title: 'Figure')
    graphic = WorkType.where(name: 'graphic').update_all(
      title: 'Graphic')
    interview = WorkType.where(name: 'interview').update_all(
      title: 'Interview')
    legal_case = WorkType.where(name: 'legal_case').update_all(
      title: 'Legal Case')
    legislation = WorkType.where(name: 'legislation').update_all(
      title: 'Legislation')
    manuscript = WorkType.where(name: 'manuscript').update_all(
      title: 'Manuscript')
    map = WorkType.where(name: 'map').update_all(
      title: 'Map')
    motion_picture = WorkType.where(name: 'motion_picture').update_all(
      title: 'Motion Picture')
    musical_score = WorkType.where(name: 'musical_score').update_all(
      title: 'Musical Score')
    pamphlet = WorkType.where(name: 'pamphlet').update_all(
      title: 'Pamphlet')
    paper_conference = WorkType.where(name: 'paper-conference').update_all(
      title: 'Conference Paper', container: 'Conference')
    patent = WorkType.where(name: 'patent').update_all(
      title: 'Patent')
    personal_communication = WorkType.where(name: 'personal_communication').update_all(
      title: 'Personal Communication')
    post = WorkType.where(name: 'post').update_all(
      title: 'Post')
    post_weblog = WorkType.where(name: 'post-weblog').update_all(
      title: 'Blog Post', container: 'Blog')
    report = WorkType.where(name: 'report').update_all(
      title: 'Report')
    review = WorkType.where(name: 'review').update_all(
      title: 'Review')
    review_book = WorkType.where(name: 'review-book').update_all(
      title: 'Book Review')
    song = WorkType.where(name: 'song').update_all(
      title: 'Song')
    speech = WorkType.where(name: 'speech').update_all(
      title: 'Speech')
    thesis = WorkType.where(name: 'thesis').update_all(
      title: 'Thesis')
    treaty = WorkType.where(name: 'treaty').update_all(
      title: 'Treaty')
    webpage = WorkType.where(name: 'webpage').update_all(
      title: 'Webpage', container: 'Website')
  end

  def down

  end
end
