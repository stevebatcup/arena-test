require 'ipaddr'
require "resolv"

class String
  def pluralise(count)
    text = "#{count} #{self}"
    count == 1 ? text : "#{text}s"
  end

  def is_valid_ipv4_address?
    return false unless self =~ Resolv::IPv4::Regex
    ip = IPAddr.new(self)
    ip.ipv4?
  end

end