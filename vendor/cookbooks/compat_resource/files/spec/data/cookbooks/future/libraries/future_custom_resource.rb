class FutureCustomResource < ChefCompat::Resource
  resource_name :future_custom_resource
  property :x
  action :create do
    converge_if_changed do
    end
  end
end
