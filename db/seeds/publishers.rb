# Publishers 
plos = Publisher.where(name: '340').first_or_create(
    :title => 'Public Library of Science (PLoS)',
    :member_id => '340',
    :other_names => <<-eos1
--- 
- Public Library of Science
- Public Library of Science (PLoS)
eos1
,
    :prefixes => <<-eos2
- '10.1371'
eos2
)
