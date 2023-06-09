# frozen_string_literal: true

require "test_helper"
require_relative "../lib/dxf/drawing"

class TestLayers < Minitest::Test
  include Dxf

  def test_that_layers_can_be_written
    layer = Layer.new("some-layer-name", 7)
    expected_code_pairs = [
      CodePair.new(0, "LAYER"),
      CodePair.new(2, "some-layer-name"),
      CodePair.new(62, 7)
    ]
    assert_array_contains(layer.code_pairs(AcadVersion::R12), expected_code_pairs)
  end

  def test_that_layer_info_can_be_read
    code_pairs = [
      CodePair.new(2, "some-layer-name"),
      CodePair.new(62, 7)
    ]
    code_pair_reader = CodePairReader.new(code_pairs)
    layer = Layer.from_code_pair_reader(code_pair_reader)
    assert_equal(2, code_pair_reader.index)
    assert_equal("some-layer-name", layer.name)
    assert_equal(7, layer.color)
  end
end
