actions :set

attribute :chain, :name_attribute => true, :equal_to => ["INPUT", "FORWARD", "OUTPUT"], :default => "INPUT"
attribute :policy, :equal_to => ["ACCEPT", "DROP"], :required => true


def initialize(*args)
  super
  @action = :set
end

