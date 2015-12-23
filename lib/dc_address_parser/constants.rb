module DcAddressParser
  CITY = "WASHINGTON, DC"

  STREET_TYPES = {
    "STREET"    => "ST",
    "AVENUE"    => "AVE",
    "BOULEVARD" => "BLVD",
    "ROAD"      => "RD",
    "PLACE"     => "PL",
    "DRIVE"     => "DR",
    "CIRCLE"    => "CIR",
    "PALZA"     => "PLZ",
    "COURT"     => "CT",
    "ALLEY"     => "AL",
    "TERRACE"   => "TER"
  }

  DIRECTIONS = {
    "NORTH" => "N",
    "SOUTH" => "S",
    "EAST"  => "E",
    "WEST"  => "W"
  }
end
