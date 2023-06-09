# frozen_string_literal: true

require "dxf"

# stuff relating to Fibonacci numbers
module Fib
  include Dxf

  def self.make_spiral(sections)
    phi = 1.618
    center = Point.new
    radius = 1.0

    drawing = Drawing.new
    (0..sections - 1).each do |i|
      quadrant = i % 4
      start_angle = quadrant * 90
      end_angle = start_angle + 90
      puts "quadrant = #{quadrant}, center = #{center}, radius = #{radius}, sa = #{start_angle}, ea = #{end_angle}"
      arc = Arc.new(center, radius, start_angle, end_angle)
      drawing.entities << arc

      center_offset = radius / phi
      case quadrant
      when 0
        center = Point.new(center.x, center.y - center_offset)
      when 1
        center = Point.new(center.x + center_offset, center.y)
      when 2
        center = Point.new(center.x, center.y + center_offset)
      when 3
        center = Point.new(center.x - center_offset, center.y)
      end
      radius *= phi
    end

    drawing.save("spiral.dxf")
  end
end

Fib.make_spiral(10)
