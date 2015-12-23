# DC Address Parser

*Parses and normalizes Washington, DC street addresses according to the DC Master Address Repository (MAR) standard.*

## Usage

```ruby
address = DcAddressParser.parse "123 main st n.w."

address.numbers
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

The Gem conforms to the [DC Master Address Repository (MAR) address standard](http://octo.dc.gov/sites/default/files/dc/sites/octo/publication/attachments/DCGIS-MarAddressStandards.pdf)

## Installing

1. Add `gem 'dc_address_parser'` to your project's Gemfile
2. `bundle install`
