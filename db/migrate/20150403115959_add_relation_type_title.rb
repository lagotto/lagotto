class AddRelationTypeTitle < ActiveRecord::Migration
  def up
    add_column :relation_types, :title, :string
    add_column :relation_types, :inverse_title, :string
    add_column :relation_types, :inverse_name, :string
    add_column :relation_types, :level, :integer, default: 1
    rename_table :events, :relations
    rename_column :relations, :citation_id, :related_work_id

    RelationType.destroy_all
    # Based on DataCite Metadata Schema 3.1: http://dx.doi.org/10.5438/0010
    # references
    cites = RelationType.where(name: 'cites').first_or_create(
      title: 'Cites', inverse_title: 'Is cited by', inverse_name: 'is_cited_by')
    is_cited_by = RelationType.where(name: 'is_cited_by').first_or_create(
      title: 'Is cited by', inverse_title: 'Cites', inverse_name: 'cites')
    is_supplement_to = RelationType.where(name: 'Is_supplement_to').first_or_create(
      title: 'Is supplement to', inverse_title: 'Is supplemented by', inverse_name: 'is_supplemented_by')
    is_supplemented_by = RelationType.where(name: 'is_supplemented_by').first_or_create(
      title: 'Is supplemented by', inverse_title: 'Is supplement to', inverse_name: 'is_supplement_to')
    continues = RelationType.where(name: 'continues').first_or_create(
      title: 'Continues', inverse_title: 'Is continued by', inverse_name: 'is_continued_by')
    is_continued_by = RelationType.where(name: 'is_continued_by').first_or_create(
      title: 'Is continued by', inverse_title: 'Continues', inverse_name: 'continues')
    is_metadata_for = RelationType.where(name: 'is_metadata_for').first_or_create(
      title: 'Is metadata for', inverse_title: 'Has metadata', inverse_name: 'has_metadata')
    has_metadata = RelationType.where(name: 'has_metadata').first_or_create(
      title: 'Has metadata', inverse_title: 'Is metadata of', inverse_name: 'is_metadata_of')
    is_part_of = RelationType.where(name: 'is_part_of').first_or_create(
      title: 'Is part of', inverse_title: 'Has part', inverse_name: 'has_part')
    has_part = RelationType.where(name: 'has_part').first_or_create(
      title: 'Has part', inverse_title: 'Is part of', inverse_name: 'is_part_of')
    references = RelationType.where(name: 'references').first_or_create(
      title: 'References', inverse_title: 'Is referenced by', inverse_name: 'is_referenced_by')
    is_referenced_by = RelationType.where(name: 'is_referenced_by').first_or_create(
      title: 'Is referenced by', inverse_title: 'References', inverse_name: 'references')
    documents = RelationType.where(name: 'documents').first_or_create(
      title: 'Documents', inverse_title: 'Is documented by', inverse_name: 'is_documented_by')
    is_documented_by = RelationType.where(name: 'is_documented_by').first_or_create(
      title: 'Is documented by', inverse_title: 'Documents', inverse_name: 'documents')
    compiles = RelationType.where(name: 'compiles').first_or_create(
      title: 'Compiles', inverse_title: 'Is compiled by', inverse_name: 'is_compiled_by')
    is_compiled_by = RelationType.where(name: 'is_compiled_by').first_or_create(
      title: 'Is compiled by', inverse_title: 'Compiles', inverse_name: 'compiles')
    reviews = RelationType.where(name: 'reviews').first_or_create(
      title: 'Reviews', inverse_title: 'Is reviewed by', inverse_name: 'is_reviewed_by')
    is_reviewed_by = RelationType.where(name: 'is_reviewed_by').first_or_create(
      title: 'Is reviewed by', inverse_title: 'Reviews', inverse_name: 'reviews')
    is_derived_from = RelationType.where(name: 'is_derived_from').first_or_create(
      title: 'Is derived from', inverse_title: 'Is source of', inverse_name: 'is_source_of')
    is_source_of = RelationType.where(name: 'is_source_of').first_or_create(
      title: 'Is source of', inverse_title: 'Is derived from', inverse_name: 'is_derived_from')

    # custom references needed for lagotto
    discusses = RelationType.where(name: 'discusses').first_or_create(
      title: 'Discusses', inverse_title: 'Is discussed by', inverse_name: 'is_discussed_by')
    is_discussed_by = RelationType.where(name: 'is_discussed_by').first_or_create(
      title: 'Is discussed by', inverse_title: 'Discusses', inverse_name: 'discusses')
    bookmarks = RelationType.where(name: 'bookmarks').first_or_create(
      title: 'Bookmarks', inverse_title: 'Is bookmarked by', inverse_name: 'is_bookmarked_by')
    is_bookmarked_by = RelationType.where(name: 'is_bookmarked_by').first_or_create(
      title: 'Is bookmarked by', inverse_title: 'Bookmarks', inverse_name: 'bookmarks')
    recommends = RelationType.where(name: 'recommends').first_or_create(
      title: 'Recommends', inverse_title: 'Is recommended by', inverse_name: 'is_recommended_by')
    is_recommended_by = RelationType.where(name: 'is_recommended_by').first_or_create(
      title: 'Is recommended by', inverse_title: 'Recommends', inverse_name: 'recommends')

    # versions
    is_new_version_of = RelationType.where(name: 'is_new_version_of').first_or_create(
      title: 'Is new version of', inverse_title: 'Is previous version of', inverse_name: 'is_previous_version_of', level: 0)
    is_previous_version_of = RelationType.where(name: 'is_previous_version_of').first_or_create(
      title: 'Is previous version of', inverse_title: 'Is new version of', inverse_name: 'is_new_version_of', level: 0)
    is_variant_form_of = RelationType.where(name: 'is_variant_form_of').first_or_create(
      title: 'Is variant form of', inverse_title: 'Is original form of', inverse_name: 'is_original_form_of', level: 0)
    is_orginal_form_of = RelationType.where(name: 'is_orginal_form_of').first_or_create(
      title: 'Is original form of', inverse_title: 'Is variant form of', inverse_name: 'is_variant_form_of', level: 0)
    is_identical_to = RelationType.where(name: 'is_identical_to').first_or_create(
      title: 'Is identical to', inverse_title: 'Is identical to', inverse_name: 'is_identical_to', level: 0)

    # custom versions needed for lagotto
    corrects = RelationType.where(name: 'corrects').first_or_create(
      title: 'Corrects', inverse_title: 'Is corrected by', inverse_name: 'is_corrected_by', level: 0)
    is_corrected_by = RelationType.where(name: 'is_corrected_by').first_or_create(
      title: 'Is corrected by', inverse_title: 'Corrects', inverse_name: 'corrects', level: 0)

    computer_program = WorkType.where(name: 'computer_program').first_or_create(
      title: 'Computer Program')
  end

  def down
    remove_column :relation_types, :title
    remove_column :relation_types, :inverse_title
    remove_column :relation_types, :inverse_name
    remove_column :relation_types, :level

    rename_column :relations, :related_work_id, :citation_id
    rename_table :relations, :events
  end
end
