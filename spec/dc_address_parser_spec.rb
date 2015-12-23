require 'spec_helper'

describe DcAddressParser do
  it 'has a version number' do
    expect(DcAddressParser::VERSION).not_to be nil
  end

  it "parses the address" do
    address = subject.parse("123 Main St NW")
    expect(address.to_s).to eql("123 MAIN STREET NW")
  end
end
