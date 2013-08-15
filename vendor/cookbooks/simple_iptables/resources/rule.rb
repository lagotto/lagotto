actions :append

attribute :chain, :name_attribute => true, :kind_of => String
attribute :rule, :kind_of => [String, Array], :required => true
attribute :jump, :kind_of => [String, FalseClass], :default => "ACCEPT"
attribute :direction, :equal_to => ["INPUT", "FORWARD", "OUTPUT"], :default => "INPUT"


def initialize(*args)
  super
  @action = :append
end

