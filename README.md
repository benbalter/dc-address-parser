# DC Address Parser

*Parses and normalizes Washington, DC street addresses according to the DC Master Address Repository (MAR) standard.*

[![Build Status](https://travis-ci.org/benbalter/dc-address-parser.svg)](https://travis-ci.org/benbalter/dc-address-parser)

## Usage

```ruby
address = DcAddressParser.parse "123 main st n.w."

address.number
=> 123

address.street_name
=> "MAIN"

address.street_type
=> "STREET"

address.quadrant
=> "NW"

address.to_s
"123 MAIN STREET NW"
```

## Address standard

The Gem conforms to the [DC Master Address Repository (MAR) address standard](http://octo.dc.gov/sites/default/files/dc/sites/octo/publication/attachments/DCGIS-MarAddressStandards.pdf). You can learn more about the MAR in the [MAR FAQ](http://octo.dc.gov/sites/default/files/dc/sites/octo/publication/attachments/DCGIS-MarFAQ.pdf).

## Looking up addresses in the MAR

The Gem integrates with the [DC Address Lookup](https://github.com/benbalter/dc-address-lookup) gem. To look up an address in the MAR:

```ruby
address.lookup
=> #<DcAddressLookup::Location>
```

## Installing

1. Add `gem 'dc_address_parser'` to your project's Gemfile
2. `bundle install`
