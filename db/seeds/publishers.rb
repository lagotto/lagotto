# Publishers 
plos = Publisher.where(name: '340').first_or_create(
    :title => 'Public Library of Science (PLoS)',
    :member_id => '340',
    :other_names => '--- \n- xPublic Library of Science\n- Public Library of Science (PLoS)',
    :prefixes => <<-eos
--- 
- '10.1371'
eos
)
