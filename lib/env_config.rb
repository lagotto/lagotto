class EnvConfig
  def self.config_for(prefix)
    @configs_by_prefix ||= {}
    @configs_by_prefix[prefix] ||= {}.tap do |config|
      vars = env_vars_for(prefix)
      vars.each do |key_tokens_str, value_str|
        keys = key_tokens_str.split('__').map{ |token| to_key(token) }
        value = is_int?(value_str) ? Integer(value_str) : value_str
        build_config_for_env_var(config, keys, value)
      end
    end
  end

  def self.build_config_for_env_var(collection, keys, value)
    if keys.size > 1
      key, next_key = keys.first(2)
      collection[key] ||= empty_collection(next_key)

      next_collection = collection[key]
      remaining_keys = keys.drop(1)
      build_config_for_env_var(next_collection, remaining_keys, value)
      next_collection
    else
      collection[keys.first] = value
    end
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
    env_vars.select{ |k,v| k.start_with?(prefix) }
  end

  def self.env_vars
    @env_vars ||= ENV.to_hash
  end
end
