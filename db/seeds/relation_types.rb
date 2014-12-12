# Load relation_types
# From the DataCite Metadata Schema 3.1: http://dx.doi.org/10.5438/0010
is_cited_by = RelationType.where(name: 'IsCitedBy').first_or_create
cites = RelationType.where(name: 'Cites').first_or_create
is_supplement_to = RelationType.where(name: 'IsSupplementTo').first_or_create
is_supplemented_by = RelationType.where(name: 'IsSupplementedBy').first_or_create
is_continued_by = RelationType.where(name: 'IsContinuedBy').first_or_create
continues = RelationType.where(name: 'Continues').first_or_create
has_metadata = RelationType.where(name: 'HasMetadata').first_or_create
is_metadata_for = RelationType.where(name: 'IsMetadataFor').first_or_create
is_new_version_of = RelationType.where(name: 'IsNewVersionOf').first_or_create
is_previous_version_of = RelationType.where(name: 'IsPreviousVersionOf').first_or_create
is_part_of = RelationType.where(name: 'IsPartOf').first_or_create
has_part = RelationType.where(name: 'HasPart').first_or_create
is_referenced_by = RelationType.where(name: 'IsReferencedBy').first_or_create
references = RelationType.where(name: 'References').first_or_create
is_documented_by = RelationType.where(name: 'IsDocumentedBy').first_or_create
documents = RelationType.where(name: 'Documents').first_or_create
is_compiled_by = RelationType.where(name: 'IsCompiledBy').first_or_create
compiles = RelationType.where(name: 'Compiles').first_or_create
is_variant_form_of = RelationType.where(name: 'IsVariantFormOf').first_or_create
is_original_form_of = RelationType.where(name: 'IsOriginalFormOf').first_or_create
is_identical_to = RelationType.where(name: 'IsIdenticalTo').first_or_create
is_reviewed_by = RelationType.where(name: 'IsReviewedBy').first_or_create
reviews = RelationType.where(name: 'Reviews').first_or_create
is_derived_from = RelationType.where(name: 'IsDerivedFrom').first_or_create
is_source_of = RelationType.where(name: 'IsSourceOf').first_or_create
