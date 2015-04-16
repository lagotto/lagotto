# Load relation_types
# Based on DataCite Metadata Schema 3.1: http://www.crossref.org/schemas/relations.xsd
cites = RelationType.where(name: 'cites').first_or_create(
  title: 'Cites')
is_supplement_to = RelationType.where(name: 'Is_supplement_to').first_or_create(
  title: 'Is supplement to')
continues = RelationType.where(name: 'continues').first_or_create(
  title: 'Continues')
is_metadata_for = RelationType.where(name: 'is_metadata_for').first_or_create(
  title: 'Is metadata for')
is_new_version_of = RelationType.where(name: 'is_new_version_of').first_or_create(
  title: 'Is new version of')
is_part_of = RelationType.where(name: 'is_part_of').first_or_create(
  title: 'Is part of')
references = RelationType.where(name: 'references').first_or_create(
  title: 'References')
documents = RelationType.where(name: 'documents').first_or_create(
  title: 'Documents')
compiles = RelationType.where(name: 'compiles').first_or_create(
  title: 'Compiles')
is_variant_form_of = RelationType.where(name: 'is_variant_form_of').first_or_create(
  title: 'Is variant form of')
is_identical_to = RelationType.where(name: 'is_identical_to').first_or_create(
  title: 'Is identical to')
reviews = RelationType.where(name: 'reviews').first_or_create(
  title: 'Reviews')
is_derived_from = RelationType.where(name: 'is_derived_from').first_or_create(
  title: 'Is derived from')
_cites = RelationType.where(name: '_cites').first_or_create(
  title: 'Is cited by', inverse: true)
_is_supplement_to = RelationType.where(name: '_is_supplement_to').first_or_create(
  title: 'Is supplemented by', inverse: true)
_continues = RelationType.where(name: '_continues').first_or_create(
  title: 'Is continued by', inverse: true)
is_metadata_for = RelationType.where(name: '_is_metadata_for').first_or_create(
  title: 'Has metadata', inverse: true)
is_new_version_of = RelationType.where(name: '_is_new_version_of').first_or_create(
  title: 'Is previous version of', inverse: true)
is_part_of = RelationType.where(name: '_is_part_of').first_or_create(
  title: 'Has part', inverse: true)
references = RelationType.where(name: '_references').first_or_create(
  title: 'Is referenced by', inverse: true)
documents = RelationType.where(name: '_documents').first_or_create(
  title: 'Is documented by', inverse: true)
compiles = RelationType.where(name: '_compiles').first_or_create(
  title: 'Is compiled by', inverse: true)
is_variant_form_of = RelationType.where(name: '_is_variant_form_of').first_or_create(
  title: 'Is original form of', inverse: true)
reviews = RelationType.where(name: '_reviews').first_or_create(
  title: 'Is reviewed by', inverse: true)
is_derived_from = RelationType.where(name: '_is_derived_from').first_or_create(
  title: 'Is source of', inverse: true)

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
  title: 'Is corrected by', inverse: true)
discusses = RelationType.where(name: '_discusses').first_or_create(
  title: 'Is discussed by', inverse: true)
bookmarks = RelationType.where(name: '_bookmarks').first_or_create(
  title: 'Is bookmarked by', inverse: true)
recommends = RelationType.where(name: '_recommends').first_or_create(
  title: 'Is recommended by', inverse: true)
