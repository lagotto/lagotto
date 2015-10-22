class AddPlosImportAgent < ActiveRecord::Migration
  def up
    other = Group.where(name: 'other').first_or_create(title: 'Other')
    plos_import = PlosImport.where(name: 'plos_import').first_or_create(
      :title => 'PLOS Import',
      :description => 'Import works via the PLOS Solr API.',
      :group_id => other.id)
  end
end
