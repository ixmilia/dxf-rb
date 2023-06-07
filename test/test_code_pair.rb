# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/code_pair"

include Dxf

class TestCodePair < Minitest::Test
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
end
