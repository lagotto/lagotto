# if Octopus.enabled?
#   Octopus.config[Rails.env.to_s]['master'] = ActiveRecord::Base.connection.config
#   ActiveRecord::Base.connection.initialize_shards(Octopus.config)
# end
