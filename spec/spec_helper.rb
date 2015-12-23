$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'dc_address_parser'
require 'webmock/rspec'

WebMock.disable_net_connect!

def test_normalizer(method, input, expected)
  address = DcAddressParser::Address.new "123 main street nw"
  address.instance_variable_set "@address", input
  address.send(method)
  expect(address.instance_variable_get("@address")).to eql(expected)
  expect(address.instance_variable_get("@raw_address")).to eql("123 main street nw")
end

def test_part(part, input, expected)
  address = DcAddressParser::Address.new input
  expect(address.send(part)).to eql(expected)
  expect(address.instance_variable_get("@raw_address")).to eql(input)
end

def test_address(input, expected)
  address = DcAddressParser::Address.new input
  expect(address.to_s).to eql(expected)
  expect(address.instance_variable_get("@raw_address")).to eql(input)
end
