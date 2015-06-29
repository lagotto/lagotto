module Reportable
  class LineItem
    def initialize(attributes={})
      @attributes = attributes.with_indifferent_access
    end

    def field(field_key)
      @attributes.fetch(field_key){
        raise("Don't have the key #{field_key.inspect}, but know about #{@attributes.keys.inspect}")
      }
    end
  end
end
