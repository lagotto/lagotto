require "rails_helper"

describe BlockRegistrar do
  subject(:registrar){ described_class.new }

  it "can store blocks by key for later retrieval" do
    block = lambda { 1 }
    registrar[:foo] = block
    expect(registrar[:foo]).to eq(block)
  end

  it "can have a default block when the key is unknown" do
    block = lambda { 2 }
    registrar.default_block = block
    expect(registrar[:unknown]).to eq(block)
  end

  context "and there is no default block" do
    it "raises an error when the key is unknown" do
      expect{
        registrar[:unknown]
      }.to raise_error(NotImplementedError, /No registered block defined for key 'unknown'/)
    end
  end

  describe '#dup' do
    let(:block_a){ lambda { "a" } }
    let(:block_b){ lambda { "b" } }
    let(:default_block){ lambda{ "default"} }

    before do
      registrar[:a] = block_a
      registrar[:b] = block_b
      registrar.default_block = default_block
    end

    it "returns a new BlockRegistrar" do
      new_registrar = registrar.dup
      expect(new_registrar).to be_kind_of(BlockRegistrar)
      expect(new_registrar).to_not be(registrar)
    end

    it "copies all of the keys and block references into the new BlockRegistrar" do
      new_registrar = registrar.dup
      expect(new_registrar[:a]).to be(block_a)
      expect(new_registrar[:b]).to be(block_b)
      expect(new_registrar[:unknown]).to be(default_block)
      expect(new_registrar.default_block).to be(default_block)
    end
  end
end
