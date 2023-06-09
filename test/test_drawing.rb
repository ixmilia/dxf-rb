# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/drawing"

class TestDrawing < Minitest::Test
  include Dxf

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

  def test_that_an_ascii_file_can_be_generated
    drawing = Drawing.new
    ascii = drawing.to_s
    assert(ascii.start_with?("  0\r\nSECTION\r\n"))
    assert(ascii.end_with?("  0\r\nEOF\r\n"))
  end

  def test_that_layers_are_written
    drawing = Drawing.new
    expected_code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "TABLES"),
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "LAYER")
    ]
    assert_array_contains(drawing.code_pairs, expected_code_pairs)
  end

  def test_that_layers_can_be_read
    code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "TABLES"),
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "LAYER"),
      CodePair.new(0, "LAYER"),
      CodePair.new(2, "some-layer"),
      CodePair.new(0, "ENDTAB"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(1, drawing.layers.length)
    assert_equal("some-layer", drawing.layers[0].name)
  end

  def test_that_multiple_layers_can_be_read
    code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "TABLES"),
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "LAYER"),
      CodePair.new(0, "LAYER"),
      CodePair.new(2, "some-layer-1"),
      CodePair.new(0, "LAYER"),
      CodePair.new(2, "some-layer-2"),
      CodePair.new(0, "ENDTAB"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(2, drawing.layers.length)
    assert_equal("some-layer-1", drawing.layers[0].name)
    assert_equal("some-layer-2", drawing.layers[1].name)
  end

  def test_that_tables_can_be_empty
    code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "TABLES"),
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "LAYER"),
      CodePair.new(0, "ENDTAB"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(0, drawing.layers.length)
  end

  def test_that_unknown_tables_are_skipped
    code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "TABLES"),
      # unknown table 1
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "UNKNOWN_TABLE_1"),
      CodePair.new(0, "UNKNOWN_TABLE_1"),
      CodePair.new(2, "some-unknown-value-1"),
      CodePair.new(0, "UNKNOWN_TABLE_1"),
      CodePair.new(2, "some-unknown-value-2"),
      CodePair.new(0, "ENDTAB"),
      # known table
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "LAYER"),
      CodePair.new(0, "LAYER"),
      CodePair.new(2, "some-layer"),
      CodePair.new(0, "ENDTAB"),
      # unknown table 2
      CodePair.new(0, "TABLE"),
      CodePair.new(2, "UNKNOWN_TABLE_2"),
      CodePair.new(0, "UNKNOWN_TABLE_2"),
      CodePair.new(2, "some-unknown-value-3"),
      CodePair.new(0, "UNKNOWN_TABLE_2"),
      CodePair.new(2, "some-unknown-value-4"),
      CodePair.new(0, "ENDTAB"),
      CodePair.new(0, "ENDSEC"),
      # entities
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "ENTITIES"),
      CodePair.new(0, "LINE"),
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]

    drawing = Drawing.from_code_pairs(code_pairs)
    assert_equal(1, drawing.layers.length)
    assert_equal("some-layer", drawing.layers[0].name)
    assert_equal(1, drawing.entities.length)
    assert_equal(Line, drawing.entities[0].class)
  end
end
