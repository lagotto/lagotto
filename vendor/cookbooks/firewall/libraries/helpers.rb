module FirewallCookbook
  module Helpers
    def port_to_s(p)
      if p && p.is_a?(Integer)
        p.to_s
      elsif p && p.is_a?(Array)
        p.join(',')
      elsif p && p.is_a?(Range)
        "#{p.first}:#{p.last}"
      end
    end
  end
end
