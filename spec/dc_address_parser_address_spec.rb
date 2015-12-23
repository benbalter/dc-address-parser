require 'spec_helper'

describe DcAddressParser::Address do

  ADDRESS = "1600 Pennsylvania ave n.w."
  subject { DcAddressParser::Address.new ADDRESS }

  it "stores the raw address" do
    expect(subject.raw_address).to eql(ADDRESS)
  end

  it "knows the street number" do
    expect(subject.number).to eql(1600)
  end

  it "parses number suffixes" do
    test_part :number_suffix, "123 1/2 main street nw", "1/2"
    test_part :number_suffix, "123 rear main street nw", "REAR"
  end

  it "parses the street name" do
    expect(subject.street_name).to eql("PENNSYLVANIA")
    expect(subject.street).to eql("PENNSYLVANIA")
  end

  it "ordinalizes the steet name" do
    test_part :street_name, "123 3 st nw", "3RD"
  end

  it "parses the street type" do
    expect(subject.street_type).to eql("AVENUE")
  end

  it "parses the quadrant" do
    expect(subject.quadrant).to eql("NW")
    expect(subject.quad).to eql("NW")
  end

  describe "unit numbers" do
    it "parses 123B" do
      test_part :unit_number, "123B main street nw", "B"
      test_address "123B main street nw", "123 MAIN STREET NW B"
    end

    it "parses 123-B" do
      test_part :unit_number, "123-B main street nw", "B"
      test_address "123-B main street nw", "123 MAIN STREET NW B"
    end

    it "parses APT 100" do
      test_part :unit_number, "123 main street nw APT 100", 100
      test_address "123 main street nw APT B", "123 MAIN STREET NW B"
    end

    it "parses UNIT B" do
      test_part :unit, "123 UNIT B main street nw", "B"
      test_part :unit, "123 main street nw UNIT B", "B"
    end

    it "parses #100" do
      test_part :unit, "123 main street nw #100", 100
    end
  end

  it "builds the address" do
    expect(subject.to_s).to eql("1600 PENNSYLVANIA AVENUE NW")
  end

  it "builds the address with the city" do
    expect(subject.to_s(true)).to eql("1600 PENNSYLVANIA AVENUE NW, WASHINGTON, DC")
  end

  describe "normalizers" do
    describe "whitespace" do
      it "strips trailing whitespace" do
        test_normalizer :normalize_whitespace,  "123 main street nw ",  "123 main street nw"
        test_address "123 main street nw ", "123 MAIN STREET NW"
      end

      it "strips internal whitespace" do
        test_normalizer :normalize_whitespace,  "123  main  street  nw",  "123 main street nw"
        test_address "123  main  street  nw", "123 MAIN STREET NW"
      end
    end

    it "upcases the address" do
      test_normalizer :normalize_case,  "123 main street nw",  "123 MAIN STREET NW"
      test_address "123 main street nw", "123 MAIN STREET NW"
    end

    describe "ranges" do
      it "flattens dashed ranges" do
        test_normalizer :normalize_ranges,  "100-101",  "100"
        test_normalizer :normalize_ranges,  "100‐101",  "100"
        test_normalizer :normalize_ranges,  "100 - 101",  "100"
        test_address "100-101 main street nw", "100 MAIN STREET NW"
      end

      it "flattens and'd ranges" do
        test_normalizer :normalize_ranges,  "100 & 101",  "100"
        test_normalizer :normalize_ranges,  "100, 200 and 300",  "100"
        test_normalizer :normalize_ranges,  "100, 200, and 300",  "100"
        test_address "100, 101, and 102 main street nw", "100 MAIN STREET NW"
      end
    end

    describe "quadrants" do
      it "removes periods" do
        test_normalizer :normalize_quadrant,  "N.W",  "NW"
        test_normalizer :normalize_quadrant,  "N.W.",  "NW"
        test_address "123 main street n.w", "123 MAIN STREET NW"
      end

      it "removes preceeding commas" do
        test_normalizer :normalize_quadrant,  "123 main street, NW",  "123 main street NW"
        test_address "123 main street, NW", "123 MAIN STREET NW"
      end
    end

    it "normalizes abbreviated street types" do
      test_normalizer :normalize_street_type, "123 MAIN ST NW",  "123 MAIN STREET NW"
      test_address "123 main st NW", "123 MAIN STREET NW"
    end

    describe "splitting" do
      it "splits before semicollons" do
        test_normalizer :split, "foo; bar",  "foo"
        test_normalizer :split, ";;foo; bar",  "foo"
        test_address "123 main street NW; foo", "123 MAIN STREET NW"
      end

      it "splits at ands" do
        test_normalizer :split, "FOO AND BAR",  "FOO"
        test_address "123 main street NW and foo", "123 MAIN STREET NW"
      end

      it "splits after quadrant" do
        test_normalizer :split, "FOO NW, BAR",  "FOO NW"
        test_address "123 main street NW, foo", "123 MAIN STREET NW"
      end

      it "splits after new lines" do
        test_normalizer :split, "FOO NW\n BAR",  "FOO NW"
        test_address "123 main street NW\n foo", "123 MAIN STREET NW"
      end
    end

    it "normalizes rear of-type addresses" do
      test_normalizer :normalize_rear, "REAR OF 123 MAIN STREET",  "123 MAIN STREET REAR"
      test_address "REAR OF 123 MAIN STREET NW", "123 MAIN STREET NW REAR"
    end

    it "normalizes spaces" do
      test_normalizer :normalize_space, "123 MAIN STREET SPACE B",  "123 MAIN STREET UNIT B"
      test_address "123 MAIN STREET NW SPACE B", "123 MAIN STREET NW B"
    end

    it "normalizes MLK" do
      test_normalizer :normalize_mlk, "123 M.L. KING JR. ST NW",  "123 MARTIN LUTHER KING JR ST NW"
      test_address "123 M.L. King JR. ST NW", "123 MARTIN LUTHER KING JR STREET NW"
    end

    describe "directions" do
      it "normalizes directions" do
        test_address "123 N CAPITAL ST NW", "123 NORTH CAPITAL STREET NW"
        test_address "123 N. CAPITAL ST NW", "123 NORTH CAPITAL STREET NW"
      end

      it "doesn't mangle N, S, E, or W street" do
        test_address "123 N ST NW", "123 N STREET NW"
      end
    end

    it "normalizes mt" do
      test_normalizer :normalize_mt, "123 MT PLEASANT ST NW",  "123 MOUNT PLEASANT ST NW"
      test_address "123 MT PLEASANT ST NW", "123 MOUNT PLEASANT STREET NW"
    end

    it "strips punctuation" do
      test_normalizer :strip_punctuation, "123 N. BEN's ALLEY N.W.",  "123 N BEN's ALLEY NW"
      test_address "123 N. BEN's ALLEY N.W.", "123 NORTH BEN'S ALLEY NW"
    end

    it "normalizes eye street" do
      test_normalizer :normalize_eye_street, "123 EYE STREET SE",  "123 I STREET SE"
      test_address "123 Eye Street SE", "123 I STREET SE"
    end
  end

  describe "match" do
    it "returns nil with no matches" do
      expect(subject.send(:match, /"abc"/)).to eql(nil)
    end

    it "returns the last match" do
      expect(subject.send(:match, /(\d+)\s([A-Z]+)/)).to eql("PENNSYLVANIA")
    end

    it "returns the requested match" do
      expect(subject.send(:match, /(\d+)\s([A-Z]+)/, 1)).to eql("1600")
    end
  end

  it "returns the address hash" do
    expected = {
      number: 1600,
      number_suffix: nil,
      street_name: "PENNSYLVANIA",
      street_type: "AVENUE",
      quadrant: "NW",
      unit_number: nil,
      city: "WASHINGTON, DC"
    }
    expect(subject.to_h).to eql(expected)
  end

  it "looks up an address" do
    url = DcAddressLookup::ENDPOINT.clone
    url << "?f=json&str=1600%20PENNSYLVANIA%20AVENUE%20NW"
    json = { returnDataset: { Table1: { foo: "bar" } } }.to_json
    stub = stub_request(:get, url).to_return(:status => 200, :body => json)
    expect(subject.lookup.class).to eql(DcAddressLookup::Location)
    expect(stub).to have_been_requested
  end

  it "accepts a hash" do
    hash = {
      street_name: "Main",
      number: "123",
      street_type: "st",
      quadrant: "n.w."
    }
    address = DcAddressParser::Address.new(hash)
    expect(address.to_s).to eql("123 MAIN STREET NW")
  end
end
