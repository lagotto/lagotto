module Reportable
  class LineItem
    attr_reader :attributes

    def initialize(attributes={})
      @attributes = attributes.with_indifferent_access
    end

    def [](field_key)
      @attributes.fetch(field_key){
        raise("Don't have the key #{field_key.inspect}, but know about #{@attributes.keys.inspect}")
      }
    end
    alias_method :field, :[]

    def []=(key, value)
      @attributes[key] = value
    end

    def ==(other)
      other.kind_of?(self.class) && other.attributes == attributes
    end
  end
end
