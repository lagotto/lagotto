require 'chef/resource'

class Chef
  class Resource
    if !method_defined?(:current_value)
      #
      # Get the current actual value of this resource.
      #
      # This does not cache--a new value will be returned each time.
      #
      # @return A new copy of the resource, with values filled in from the actual
      #   current value.
      #
      def current_value
        provider = provider_for_action(Array(action).first)
        if provider.whyrun_mode? && !provider.whyrun_supported?
          raise "Cannot retrieve #{self.class.current_resource} in why-run mode: #{provider} does not support why-run"
        end
        provider.load_current_resource
        provider.current_resource
      end
    end
  end
end
