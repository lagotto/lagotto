class BlockRegistrar
  attr_accessor :default_block

  def initialize
    @blocks_by_key = {}
  end

  def [](key)
    @blocks_by_key.fetch(key.to_sym) do
      if @default_block
        @default_block
      else
        raise NotImplementedError, "No registered block defined for key '#{key}' in #{self.inspect}"
      end
    end
  end

  def []=(key,value)
    @blocks_by_key[key.to_sym] = value
  end

  def dup
    BlockRegistrar.new.tap do |br|
      br.default_block = @default_block
      @blocks_by_key.each_pair do |key, value|
        br[key] = value
      end
    end
  end
end
