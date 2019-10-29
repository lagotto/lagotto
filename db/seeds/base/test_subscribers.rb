# seed what you need to allow you to test a subscriber with this line:
# Source.find_by(name: 'simple_source').retrieval_statuses.last.perform_get_data

cited = Group.where(name: 'cited').first_or_create(title: 'Cited')
source = SimpleSource.where(name: 'simple_source').first_or_create(
    :type        => 'SimpleSource',
    :name        => 'simple_source',
    :title       => 'Simple Source',
    :config      => OpenStruct.new(step: 5),
    :group_id    => cited.id,
    :private     => 0,
    :state_event => 'inactivate',
    :description => 'Simple Source returns an ever-increasing number',
    :queueable   => 1,
    :eventable   => 1,
    :state       => 5 # active
)
work = Work.first_or_create(
    doi: '10.1371/journal.pcbi.0010052',
    pid: 'http://doi.org/10.1371/journal.pcbi.0010052',
    title: 'Bioinformatics Education—Perspectives and Challenges',
    tracked: true
)
rs = RetrievalStatus.first_or_create(
    source_id: source.id,
    work_id: work.id
)
