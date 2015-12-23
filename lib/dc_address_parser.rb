require "dc_address_parser/version"
require "dc_address_parser/constants"

require "dc_address_parser/address"
require "active_support/inflector"
require "dc_address_lookup"

module DcAddressParser
  def self.parse(address)
    Address.new(address)
  end
end
