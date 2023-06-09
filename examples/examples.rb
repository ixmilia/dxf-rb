# frozen_string_literal: true

require "dxf"

# some examples
module Examples
  include Dxf

  def self.write_dxf_drawing
    drawing = Drawing.new
    drawing.entities << Line.new(Point.new(0, 0, 0), Point.new(10, 10, 0))
    drawing.save("drawing.dxf")
  end
end

Examples.write_dxf_drawing
