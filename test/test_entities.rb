# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/drawing"
require_relative "../lib/dxf/entities/entity"
require_relative "../lib/dxf/entities/line"

class TestEntities < Minitest::Test
  def load_entity(entity_type, code_pairs)
    all_code_pairs = [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "ENTITIES"),
      CodePair.new(0, entity_type)
    ] + code_pairs + [
      CodePair.new(0, "ENDSEC"),
      CodePair.new(0, "EOF")
    ]
    drawing = Drawing.from_code_pairs(all_code_pairs)
    assert_equal(1, drawing.entities.length)
    drawing.entities[0]
  end

  def test_that_common_properties_can_be_read
    entity = load_entity("LINE", [
      CodePair.new(8, "some-layer-name")
    ])
    assert_equal("some-layer-name", entity.layer)
  end

  def test_that_a_line_can_be_read
    line = load_entity("LINE", [
      CodePair.new(10, 1.0),
      CodePair.new(20, 2.0),
      CodePair.new(30, 3.0),
      CodePair.new(11, 4.0),
      CodePair.new(21, 5.0),
      CodePair.new(31, 6.0)
    ])
    assert_equal(Line, line.class)
    assert_equal(Point.new(1.0, 2.0, 3.0), line.p1)
    assert_equal(Point.new(4.0, 5.0, 6.0), line.p2)
  end
end
