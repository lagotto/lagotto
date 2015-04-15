# Load relation_types
# Based on DataCite Metadata Schema 3.1: http://dx.doi.org/10.5438/0010
cites = RelationType.where(name: 'cites').first_or_create(
  title: 'Cites', inverse_title: 'Is cited by')
is_supplement_to = RelationType.where(name: 'Is_supplement_to').first_or_create(
  title: 'Is supplement to', inverse_title: 'Is supplemented by')
continues = RelationType.where(name: 'continues').first_or_create(
  title: 'Continues', inverse_title: 'Is continued by')
is_metadata_for = RelationType.where(name: 'is_metadata_for').first_or_create(
  title: 'Is metadata for', inverse_title: 'Has metadata')
is_new_version_of = RelationType.where(name: 'is_new_version_of').first_or_create(
  title: 'Is new version of', inverse_title: 'Is previous version of')
is_part_of = RelationType.where(name: 'is_part_of').first_or_create(
  title: 'Is part of', inverse_title: 'Has part')
references = RelationType.where(name: 'references').first_or_create(
  title: 'References', inverse_title: 'Is referenced by')
documents = RelationType.where(name: 'documents').first_or_create(
  title: 'Documents', inverse_title: 'Is documented by')
compiles = RelationType.where(name: 'compiles').first_or_create(
  title: 'Compiles', inverse_title: 'Is compiled by')
is_variant_form_of = RelationType.where(name: 'is_variant_form_of').first_or_create(
  title: 'Is variant form of', inverse_title: 'Is original form of')
is_identical_to = RelationType.where(name: 'is_identical_to').first_or_create(
  title: 'Is identical to', inverse_title: 'Is identical to')
reviews = RelationType.where(name: 'reviews').first_or_create(
  title: 'Reviews', inverse_title: 'Is reviewed by')
is_derived_from = RelationType.where(name: 'is_derived_from').first_or_create(
  title: 'Is derived from', inverse_title: 'Is source of')
_cites = RelationType.where(name: '_cites').first_or_create(
  title: 'Is cited by')
_is_supplement_to = RelationType.where(name: '_is_supplement_to').first_or_create(
  title: 'Is supplemented by')
_continues = RelationType.where(name: '_continues').first_or_create(
  title: 'Is continued by')
is_metadata_for = RelationType.where(name: '_is_metadata_for').first_or_create(
  title: 'Has metadata')
is_new_version_of = RelationType.where(name: '_is_new_version_of').first_or_create(
  title: 'Is previous version of')
is_part_of = RelationType.where(name: '_is_part_of').first_or_create(
  title: 'Has part')
references = RelationType.where(name: '_references').first_or_create(
  title: 'Is referenced by')
documents = RelationType.where(name: '_documents').first_or_create(
  title: 'Is documented by')
compiles = RelationType.where(name: '_compiles').first_or_create(
  title: 'Is compiled by')
is_variant_form_of = RelationType.where(name: '_is_variant_form_of').first_or_create(
  title: 'Is original form of')
reviews = RelationType.where(name: '_reviews').first_or_create(
  title: 'Is reviewed by')
is_derived_from = RelationType.where(name: '_is_derived_from').first_or_create(
  title: 'Is source of')

# custom relation types needed for lagotto
corrects = RelationType.where(name: 'corrects').first_or_create(
  title: 'Corrects')
discusses = RelationType.where(name: 'discusses').first_or_create(
  title: 'Discusses')
bookmarks = RelationType.where(name: 'bookmarks').first_or_create(
  title: 'Bookmarks')
recommends = RelationType.where(name: 'recommends').first_or_create(
  title: 'Recommends')
corrects = RelationType.where(name: '_corrects').first_or_create(
  title: 'Is corrected by')
discusses = RelationType.where(name: '_discusses').first_or_create(
  title: 'Is discussed by')
bookmarks = RelationType.where(name: '_bookmarks').first_or_create(
  title: 'Is bookmarked by')
recommends = RelationType.where(name: '_recommends').first_or_create(
  title: 'Is recommended by')
