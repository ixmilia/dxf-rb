# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/header"

class TestHeader < Minitest::Test
  include Dxf

  def test_that_header_can_be_parsed
    code_pairs = [
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1014"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(9, "$ACADVER"), # this should be ignored because it's past [0/ENDSEC]
      CodePair.new(1, "AC1015")
    ]
    header = Header.from_code_pair_reader(CodePairReader.new(code_pairs))
    assert_equal(AcadVersion::R14, header.version)
  end

  def test_that_code_pairs_can_be_generated
    header = Header.new
    header.version = AcadVersion::R14
    header.minimum_drawing_extents = Point.new(0, 0, 0)
    header.maximum_drawing_extents = Point.new(100, 100, 0)
    expected_code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "HEADER"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1014"),
      CodePair.new(9, "$ACADMAINTVER"),
      CodePair.new(70, 0),
      CodePair.new(9, "$EXTMIN"),
      CodePair.new(10, 0.0),
      CodePair.new(20, 0.0),
      CodePair.new(30, 0.0),
      CodePair.new(9, "$EXTMAX"),
      CodePair.new(10, 100.0),
      CodePair.new(20, 100.0),
      CodePair.new(30, 0.0),
      CodePair.new(0, "ENDSEC")
    ]
    actual_code_pairs = header.code_pairs
    assert_equal(expected_code_pairs, actual_code_pairs)
  end
end
