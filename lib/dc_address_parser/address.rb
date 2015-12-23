module DcAddressParser
  class Address
    class InvalidAddress < StandardError; end

    attr_reader :raw_address

    NUMBER_REGEX          = /\A(\d+)[A-Z]*/
    NUMBER_SUFFIX_REGEX   = /(\d+\/\d+|rear)/i
    STREET_NAME_REGEX     = /([A-Z0-9' ]+)/
    STREET_TYPE_REGEX     = /\b(#{Regexp.union(DcAddressParser::STREET_TYPES.keys)})\b/
    STREET_TYPE_ABV_REGEX = /\b(#{Regexp.union(DcAddressParser::STREET_TYPES.values)})\b/
    QUADRANT_REGEX        = /([NS][EW])/

    PARTS = [:number, :number_suffix, :street_name, :street_type, :quadrant, :unit_number]
    REQUIRED_PARTS = [:number, :street_name, :street_type, :quadrant]

    def initialize(address_or_hash)
      if address_or_hash.class == Hash
        address_or_hash = PARTS.clone.map { |part| address_or_hash[part] }.compact.join(" ")
      end
      @raw_address = @address = address_or_hash

      normalize!
      REQUIRED_PARTS.each do |part|
        raise InvalidAddress, "#{part.to_s.sub("_", " ")} is missing" if send(part).nil?
      end
    end

    def number
      @number ||= match(NUMBER_REGEX).to_i
    end

    def number_suffix
      @number_suffix ||= match(/#{number}\s#{NUMBER_SUFFIX_REGEX}/)
    end
    alias_method :suffix, :number_suffix

    def street_name
      @street_name ||= begin
        street_name = match(
        /#{number}(-?#{unit_number}|\s#{Regexp.escape number_suffix.to_s})?
        \s#{STREET_NAME_REGEX}\s(?=#{STREET_TYPE_REGEX})/x, 2)

        if street_name =~ /\A[0-9]+\z/
          street_name = ActiveSupport::Inflector.ordinalize(street_name).upcase
        end

        street_name
      end
    end
    alias_method :street, :street_name

    def street_type
      @street_type ||= match(STREET_TYPE_REGEX) || "STREET"
    end

    def quadrant
      @quadrant ||= match QUADRANT_REGEX
    end
    alias_method :quad, :quadrant

    def unit_number
      @unit_number ||= begin
        unit_number = match(/\A(\d+)(-|–)?([A-Z])\b/) ||
          match(/\s(UNIT\s|APT\s|#)([A-Z0-9]+)(\s|\z)/, 2) ||
          match(/#{quadrant}\s([A-Z0-9]+)\z/)
        if unit_number =~ /\A\d+\z/
          unit_number.to_i
        else
          unit_number
        end
      end
    end
    alias_method :unit, :unit_number

    def to_h
      hash = {}
      PARTS.each { |part| hash[part] = send(part) }
      hash.merge({city: DcAddressParser::CITY})
    end

    def to_s(include_city=false)
      parts = to_h
      if include_city
        parts[:quadrant] << ","
      else
        parts.delete(:city)
      end
      parts.values.compact.join(" ")
    end

    def lookup
      DcAddressLookup.lookup to_s
    end

    def inspect
      "#<DcAddressParser::Address address=\"#{to_s}\">"
    end

    private

    def normalize!
      normalize_whitespace
      normalize_case
      normalize_ranges
      normalize_quadrant
      normalize_street_type
      normalize_rear
      normalize_space
      normalize_mlk
      normalize_directions
      normalize_mt
      split
    end

    def normalize_whitespace
      @address = @address.strip.squeeze("\s").squeeze("'")
    end

    def normalize_case
      @address = @address.upcase
    end

    def normalize_ranges
      @address.gsub!(/\A(\d+)\s?(-|–|&)\s?\d+/, '\1')
      @address.gsub!(/(\d+), \d+,? and \d+/i, '\1')
    end

    def normalize_quadrant
      @address.gsub!(/([NS])\.([EW])\.?/, '\1\2')
      @address.gsub!(/, ([NS][EW])/, ' \1')
    end

    def normalize_street_type
      @address.gsub!(STREET_TYPE_ABV_REGEX, DcAddressParser::STREET_TYPES.invert)
    end

    def normalize_rear
      regex = /\AREAR OF (\d+)/
      return unless @address =~ regex
      @address.gsub!(/\AREAR OF (\d+)/, '\1')
      @address << " REAR"
    end

    def normalize_space
      @address.gsub!(/\bSPACE\b/, "UNIT")
    end

    def normalize_mlk
      @address.gsub!(/\bM\.?L\.? KING\b/, "MARTIN LUTHER KING")
      @address.gsub!(/\bJR\./, "JR")
    end

    def normalize_directions
      regex = /\b(#{Regexp.union DcAddressParser::DIRECTIONS.values})(?=\s+|\.)/
      @address.gsub!(regex, DcAddressParser::DIRECTIONS.invert)
    end

    def normalize_mt
      @address.gsub!(/\bMT\b/, "MOUNT")
    end

    def split
      @address = @address.split(";").reject { |s| s.empty? }.first.to_s
      @address = @address.split(/\bAND\b/).first.to_s.strip
      @address = @address.split(/\b([NS][EW]),/)[0..1].join
    end

    def match(regex, number=nil)
      matches = @address.match(regex)
      return unless matches
      return matches[number] if number
      matches.to_a.last
    end
  end
end
