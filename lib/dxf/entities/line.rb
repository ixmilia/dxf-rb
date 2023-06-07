# frozen_string_literal: true

require_relative "entity"
require_relative "../point"

# Represents a `LINE` entity.
class Line < Entity
  attr_accessor :p1, :p2

  def initialize(p1 = Point.new(0.0, 0.0, 0.0), p2 = Point.new(0.0, 0.0, 0.0))
    super()
    @p1 = p1
    @p2 = p2
  end

  def self.from_code_pairs(code_pairs, start_index)
    next_index = start_index
    line = Line.new

    code_pairs[start_index..].each_with_index do |code_pair, index|
      next_index = start_index + index + 1

      break if code_pair.code == 0

      line.try_set_code_pair(code_pair)
    end

    return line, next_index
  end

  def try_set_code_pair(code_pair)
    case code_pair.code
    when 10
      @p1.x = code_pair.value
    when 20
      @p1.y = code_pair.value
    when 30
      @p1.z = code_pair.value
    when 11
      @p2.x = code_pair.value
    when 21
      @p2.y = code_pair.value
    when 31
      @p2.z = code_pair.value
    else
      super(code_pair)
    end
  end
end
