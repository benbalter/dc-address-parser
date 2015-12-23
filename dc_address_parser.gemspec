# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dc_address_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "dc_address_parser"
  spec.version       = DcAddressParser::VERSION
  spec.authors       = ["Ben Balter"]
  spec.email         = ["ben.balter@github.com"]

  spec.summary       = "Parses and normalizes Washington, DC street addresses according to the DC Master Address Repository (MAR) standard."
  spec.homepage      = "https://github.com/benbalter/dc-address-parser"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.2"
  spec.add_dependency "dc_address_lookup", "~> 0.2"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "webmock", "~> 1.22"
end
