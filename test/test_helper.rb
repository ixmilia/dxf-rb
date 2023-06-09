# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "dxf"

require "minitest/autorun"

def assert_array_contains(array, sub_sequence)
  found_sequence = false
  (0..array.length - sub_sequence.length).each do |i|
    candidate_sequence = array.slice(i, sub_sequence.length)
    if candidate_sequence.zip(sub_sequence).all? { |a, b| a == b }
      found_sequence = true
      break
    end
  end

  assert found_sequence, "Array\n  #{array.join("\n  ")}\ndoes not contain\n  #{sub_sequence.join("\n  ")}"
end
