require 'dxf'

include Dxf

def write_dxf_drawing
  drawing = Drawing.new
  drawing.entities << Line.new(Point.new(0, 0, 0), Point.new(10, 10, 0))
  drawing.save('drawing.dxf')
end

write_dxf_drawing
