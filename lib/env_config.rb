class EnvConfig
  def self.config_for(prefix)
    {}.tap do |top_config|
      env_vars = env_vars_for(prefix)
      env_vars.each do |env_key, env_value|
        add_to_config(env_key, env_value, top_config)
      end
    end
  end

  def self.add_to_config(env_key, env_value, config)
    ancestors = env_key.split('__').map{ |kp| to_key(kp) }
    temp_config = config
    # initialize empty structure for env var
    ancestors.each_with_index do |parent_key, index|
      # skip the last key; it will hold the value
      break if index == ancestors.size - 1

      # initialize hash or array when child represents a hash key or array index
      child_key = ancestors[index + 1]
      temp_config[parent_key] ||= empty_collection(child_key)
      temp_config = temp_config[parent_key]
    end

    # [] is same syntax for hash and array. Arg types differ (Integer vs Symbol)
    temp_config[ancestors.last] = env_value
  end

  def self.is_array_index(key_str)
    key_str.match(/^\d+$/)
  end

  def self.to_key(key_str)
    if is_array_index(key_str)
      Integer(key_str)
    else 
      key_str.downcase.to_sym  
    end
  end
  
  def self.empty_collection(key)
    key.is_a?(Integer) ? [] : {}
  end

  def self.env_vars_for(prefix)
    ENV.select{ |k,v| k.start_with?(prefix) }
  end
end
