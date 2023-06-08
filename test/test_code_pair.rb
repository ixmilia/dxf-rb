# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/code_pair"

class TestCodePair < Minitest::Test
  include Dxf

  def test_that_code_pairs_can_be_parsed_with_trailing_newline
    code_pairs = CodePair.pairs_from_text("0\nSECTION\n2\nENTITIES\n0\nENDSEC\n0\nEOF\n")
    assert_equal(4, code_pairs.length)
    assert_equal(0, code_pairs[0].code)
    assert_equal("SECTION", code_pairs[0].value)
    assert_equal(2, code_pairs[1].code)
    assert_equal("ENTITIES", code_pairs[1].value)
    assert_equal(0, code_pairs[2].code)
    assert_equal("ENDSEC", code_pairs[2].value)
    assert_equal(0, code_pairs[3].code)
    assert_equal("EOF", code_pairs[3].value)
  end

  def test_that_code_pairs_can_be_parsed_without_trailing_newline
    code_pairs = CodePair.pairs_from_text("0\nSECTION\n2\nENTITIES\n0\nENDSEC\n0\nEOF")
    assert_equal(4, code_pairs.length)
    assert_equal(0, code_pairs[0].code)
    assert_equal("SECTION", code_pairs[0].value)
    assert_equal(2, code_pairs[1].code)
    assert_equal("ENTITIES", code_pairs[1].value)
    assert_equal(0, code_pairs[2].code)
    assert_equal("ENDSEC", code_pairs[2].value)
    assert_equal(0, code_pairs[3].code)
    assert_equal("EOF", code_pairs[3].value)
  end

  def test_that_code_pairs_can_be_parsed_with_crlf
    code_pairs = CodePair.pairs_from_text("0\r\nSECTION\r\n2\r\nENTITIES\r\n0\r\nENDSEC\r\n0\r\nEOF")
    assert_equal(4, code_pairs.length)
    assert_equal(0, code_pairs[0].code)
    assert_equal("SECTION", code_pairs[0].value)
    assert_equal(2, code_pairs[1].code)
    assert_equal("ENTITIES", code_pairs[1].value)
    assert_equal(0, code_pairs[2].code)
    assert_equal("ENDSEC", code_pairs[2].value)
    assert_equal(0, code_pairs[3].code)
    assert_equal("EOF", code_pairs[3].value)
  end

  def test_that_code_pairs_can_be_parsed_with_leading_spaces
    code_pairs = CodePair.pairs_from_text("  0\nSECTION\n 10\n 1.0 ")
    assert_equal(2, code_pairs.length)
    assert_equal(0, code_pairs[0].code)
    assert_equal("SECTION", code_pairs[0].value)
    assert_equal(10, code_pairs[1].code)
    assert_equal(1.0, code_pairs[1].value)
  end

  def test_that_code_pair_string_values_retain_leading_and_trailing_spaces
    code_pairs = CodePair.pairs_from_text("  0\n  some string  \n")
    assert_equal(1, code_pairs.length)
    assert_equal(0, code_pairs[0].code)
    assert_equal("  some string  ", code_pairs[0].value)
  end

  def test_that_code_pairs_are_formatted_as_ascii_correctly
    # codes are padded to 3 spaces
    # strings are left aligned
    assert_equal("  0\r\nSECTION\r\n", CodePair.new(0, "SECTION").to_ascii)
    assert_equal("999\r\nCOMMENT\r\n", CodePair.new(999, "COMMENT").to_ascii)
    assert_equal("1001\r\nSECTION\r\n", CodePair.new(1001, "SECTION").to_ascii)
    # short values are padded to 6 spaces
    assert_equal(" 70\r\n     1\r\n", CodePair.new(70, 1).to_ascii)
    assert_equal(" 70\r\n    10\r\n", CodePair.new(70, 10).to_ascii)
    assert_equal(" 70\r\n   100\r\n", CodePair.new(70, 100).to_ascii)
    assert_equal(" 70\r\n  1000\r\n", CodePair.new(70, 1000).to_ascii)
    assert_equal(" 70\r\n 10000\r\n", CodePair.new(70, 10_000).to_ascii)
    assert_equal(" 70\r\n100000\r\n", CodePair.new(70, 100_000).to_ascii)
    # int values are padded to 9 spaces
    assert_equal(" 90\r\n        1\r\n", CodePair.new(90, 1).to_ascii)
    assert_equal(" 90\r\n       10\r\n", CodePair.new(90, 10).to_ascii)
    assert_equal(" 90\r\n      100\r\n", CodePair.new(90, 100).to_ascii)
    assert_equal(" 90\r\n     1000\r\n", CodePair.new(90, 1000).to_ascii)
    assert_equal(" 90\r\n    10000\r\n", CodePair.new(90, 10_000).to_ascii)
    assert_equal(" 90\r\n   100000\r\n", CodePair.new(90, 100_000).to_ascii)
    assert_equal(" 90\r\n  1000000\r\n", CodePair.new(90, 1_000_000).to_ascii)
    assert_equal(" 90\r\n 10000000\r\n", CodePair.new(90, 10_000_000).to_ascii)
    assert_equal(" 90\r\n100000000\r\n", CodePair.new(90, 100_000_000).to_ascii)
    # double values are always written with at least one decimal place
    assert_equal(" 40\r\n1.0\r\n", CodePair.new(40, 1.0).to_ascii)
    assert_equal(" 40\r\n1.5\r\n", CodePair.new(40, 1.5).to_ascii)
    assert_equal(" 40\r\n1.25\r\n", CodePair.new(40, 1.25).to_ascii)
  end
end
