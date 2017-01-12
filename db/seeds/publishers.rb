# Publishers 
plos = Publisher.where(name: '340').first_or_create(
    :title => 'Public Library of Science (PLoS)',
    :member_id => '340',
    :other_names => ["Public Library of Science", "Public Library of Science (PLoS)"],
    :prefixes => "10.1371")
