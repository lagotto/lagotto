class EnvConfig
  def self.config_for(prefix)
    {}.tap do |top_config|
      env_vars = env_vars_for(prefix)
      env_vars.each do |env_key, env_value|
        add_to_config(env_key, env_value, top_config)
      end
    end
  end

  def self.add_to_config(key_str, value_str, config)
    temp_config = config
    ancestors = key_str.split('__').map{ |part| to_key(part) }
    ancestors.each_with_index do |parent_key, index|
      # do not initialize a collection for the last key
      break if index == ancestors.size - 1

      # initialize collection for key - array for int key, hash for string key
      child_key = ancestors[index + 1]
      temp_config[parent_key] ||= empty_collection(child_key)
      temp_config = temp_config[parent_key]
    end

    # the last key gets the value
    value = is_int?(value_str) ? Integer(value_str) : value_str
    temp_config[ancestors.last] = value
  end

  def self.is_int?(str)
    str.match(/^\d+$/)
  end

  def self.to_key(str)
    if is_int?(str)
      Integer(str)
    else
      str.downcase.to_sym
    end
  end

  def self.empty_collection(key)
    key.is_a?(Integer) ? [] : {}
  end

  def self.env_vars_for(prefix)
    ENV.select{ |k,v| k.start_with?(prefix) }
  end
end
