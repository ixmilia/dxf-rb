# frozen_string_literal: true

module Dxf
  # Represents a `LINE` entity.
  class Line < Entity
    attr_accessor :p1, :p2
    attr_reader :type

    def initialize(p1 = Point.new(0.0, 0.0, 0.0), p2 = Point.new(0.0, 0.0, 0.0))
      super()
      @type = "LINE"
      @p1 = p1
      @p2 = p2
    end

    def specific_code_pairs(_version)
      [
        CodePair.new(10, @p1.x),
        CodePair.new(20, @p1.y),
        CodePair.new(30, @p1.z),
        CodePair.new(11, @p2.x),
        CodePair.new(21, @p2.y),
        CodePair.new(31, @p2.z)
      ]
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
end
