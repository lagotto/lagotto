# Publishers 
plos = Publisher.where(name: '340').first_or_create(
    :title => 'Public Library of Science (PLoS)',
    :member_id => '340',
    :prefixes => "--- \n- '10.1371'",
    :other_names => '--- \n- xPublic Library of Science\n- Public Library of Science (PLoS)')
