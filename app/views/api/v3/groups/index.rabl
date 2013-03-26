collection @groups, :object_root => false
  
attributes :name

child :sources => :sources do
  attributes :name, :display_name, :description
end