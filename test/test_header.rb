# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/header"

class TestHeader < Minitest::Test
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
end
