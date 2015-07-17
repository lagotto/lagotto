class AddDataoneSource < ActiveRecord::Migration
  def up
    viewed = Group.where(name: 'viewed').first_or_create(title: 'Viewed')

    dataone_counter = DataoneCounter.where(name: 'dataone_counter').first_or_create(
      :title => 'DataONE Counter',
      :description => 'COUNTER Usage data for the DataONE network of ecological and environmental data centers.',
      :eventable => false,
      :group_id => viewed.id)
    dataone_usage = DataoneUsage.where(name: 'dataone_usage').first_or_create(
      :title => 'DataONE Usage',
      :description => 'Usage data for the DataONE network of ecological and environmental data centers.',
      :eventable => false,
      :group_id => viewed.id)
  end
end
