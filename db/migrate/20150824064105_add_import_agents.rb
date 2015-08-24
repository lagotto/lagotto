class AddImportAgents < ActiveRecord::Migration
  def up
    other = Group.where(name: 'other').first_or_create(title: 'Other')

    plos_import = PlosImport.where(name: 'plos_import').first_or_create(
      :title => 'PLOS Import',
      :description => 'Import works via the PLOS Solr API.',
      :kind => "all",
      :group_id => other.id)
    crossref_import = CrossrefImport.where(name: 'crossref_import').first_or_create(
      :title => 'CrossRef Import',
      :description => 'Import works via the CrossRef REST API.',
      :kind => "all",
      :group_id => other.id)
    datacite_import = DataciteImport.where(name: 'datacite_import').first_or_create(
      :title => 'DataCite Import',
      :description => 'Import works via the DataCite Solr API.',
      :kind => "all",
      :group_id => other.id)
    dataone_import = DataoneImport.where(name: 'dataone_import').first_or_create(
      :title => 'DataONE Import',
      :description => 'Import works via the DataONE Solr API.',
      :kind => "all",
      :group_id => other.id)
  end

  def down

  end
end
