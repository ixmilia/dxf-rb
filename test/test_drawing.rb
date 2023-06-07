# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/drawing"

class TestDrawing < Minitest::Test
  def test_that_drawing_can_be_loaded_from_code_pairs
    code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "HEADER"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1014"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(AcadVersion::R14, drawing.header.version)
  end

  def test_that_drawing_can_be_parsed_from_text
    drawing = Drawing.parse("
  0
SECTION
  2
HEADER
  9
$ACADVER
  1
AC1014
  0
ENDSEC
  0
EOF".strip)
    assert_equal(AcadVersion::R14, drawing.header.version)
  end

  def test_that_unknown_sections_are_skipped
    code_pairs = [
      # this is skipped
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "NOT_A_SUPPORTED_SECTION"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1018"),
      CodePair.new(0, "ENDSEC"),
      # this is read
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "HEADER"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1014"),
      CodePair.new(0, "ENDSEC"),
      # this is skipped
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "STILL_NOT_A_SUPPORTED_SECTION"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, "AC1020"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(AcadVersion::R14, drawing.header.version)
  end
end
