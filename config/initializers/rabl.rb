Rabl.configure do |config|
  # Commented as these are defaults
  config.cache_all_output = true
  config.cache_sources = true # Rails.env != 'development' # Defaults to false
  # config.cache_engine = Rabl::CacheEngine.new # Defaults to Rails cache
  # config.perform_caching = false
  # config.escape_all_output = false
  # config.json_engine = nil # Class with #dump class method (defaults JSON)
  # config.msgpack_engine = nil # Defaults to ::MessagePack
  # config.bson_engine = nil # Defaults to ::BSON
  # config.plist_engine = nil # Defaults to ::Plist::Emit
  config.include_json_root = false
  # config.include_msgpack_root = true
  # config.include_bson_root = true
  # config.include_plist_root = true
  # config.include_xml_root  = false
  config.include_child_root = false
  config.enable_json_callbacks = true
  config.xml_options = { :dasherize  => false, :skip_types => true }
  config.view_paths = [Rails.root.join("app/views/api")]
  # config.raise_on_missing_attribute = true # Defaults to false
end
