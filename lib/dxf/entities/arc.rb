# frozen_string_literal: true

module Dxf
  # Represents a `ARC` entity.
  class Arc < Entity
    attr_accessor :center, :radius, :start_angle, :end_angle
    attr_reader :type

    def initialize(center, radius, start_angle, end_angle)
      super()
      @type = "ARC"
      @center = center
      @radius = radius
      @start_angle = start_angle
      @end_angle = end_angle
    end

    def specific_code_pairs(_version)
      [
        CodePair.new(10, @center.x),
        CodePair.new(20, @center.y),
        CodePair.new(30, @center.z),
        CodePair.new(40, @radius),
        CodePair.new(50, @start_angle),
        CodePair.new(51, @end_angle)
      ]
    end

    def self.from_code_pair_reader(code_pair_reader)
      arc = Arc.new

      until code_pair_reader.current.code == 0
        arc.try_set_code_pair(code_pair_reader.current)
        code_pair_reader.move_next
      end

      return arc
    end

    def try_set_code_pair(code_pair)
      case code_pair.code
      when 10
        @center.x = code_pair.value
      when 20
        @center.y = code_pair.value
      when 30
        @center.z = code_pair.value
      when 40
        @radius = code_pair.value
      when 50
        @start_angle = code_pair.value
      when 51
        @end_angle = code_pair.value
      else
        super(code_pair)
      end
    end
  end
end
