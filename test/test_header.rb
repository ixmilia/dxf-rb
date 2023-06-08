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
    header, next_index = Header.from_code_pairs(code_pairs, 0)
    assert_equal(3, next_index)
    assert_equal(AcadVersion::R14, header.version)
  end

  def test_that_code_pairs_can_be_generated
    header = Header.new
    header.version = AcadVersion::R14
    expected_code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "HEADER"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1014"),
      CodePair.new(0, "ENDSEC")
    ]
    actual_code_pairs = header.code_pairs
    assert_equal(expected_code_pairs, actual_code_pairs)
  end
end
