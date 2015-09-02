require 'poise'

class Chef
  class Resource::FirewallRule < Resource
    include Poise(Chef::Resource::Firewall)

    actions(:reject, :allow, :deny, :masquerade, :redirect, :log, :remove)

    attribute(:protocol, :kind_of => [Integer, Symbol, String], :callbacks => { 'must be either "tcp", "udp", "icmp" or a valid IP protocol number' => ->(p) { valid_protocol?(p) } }, :default => :tcp)
    attribute(:direction, :kind_of => [Symbol, String], :equal_to => [:in, :out, :pre, :post, 'in', 'out', 'pre', 'post'], :default => :in)
    attribute(:logging, :kind_of => [Symbol, String], :equal_to => [:connections, :packets, 'connections', 'packets'])

    attribute(:source, :callbacks => { 'must be a valid ip address' => ->(s) { valid_ip?(s) } })
    attribute(:source_port, :kind_of => [Integer, Array, Range]) # source port
    attribute(:interface, :kind_of => String)

    attribute(:port, :kind_of => [Integer, Array, Range]) # shorthand for dest_port
    attribute(:destination, :callbacks => { 'must be a valid ip address' => ->(s) { valid_ip?(s) } })
    attribute(:dest_port, :kind_of => [Integer, Array, Range])
    attribute(:dest_interface, :kind_of => String)

    attribute(:position, :kind_of => Integer)
    attribute(:stateful, :kind_of => [Symbol, String, Array])
    attribute(:redirect_port, :kind_of => Integer)
    attribute(:description, :kind_of => String, :name_attribute => true)

    # for when you just want to pass a raw rule
    attribute(:raw, :kind_of => String)

    def self.valid_ip?(ip)
      IPAddr.new(ip) ? true : false
    rescue
      false
    end

    def self.valid_protocol?(p)
      case p.to_s
      when /^\d+$/
        p.between?(0, 142) ? true : false
      when /(udp|tcp|icmp)/
        return true
      else
        return false
      end
    end
  end
end
