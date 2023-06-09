# frozen_string_literal: true

module Dxf
  # Represents a layer in a DXF file.
  class Layer < TableItem
    attr_accessor :color

    def initialize(name, color)
      super(name)
      @type = "LAYER"
      @color = color
    end

    def specific_code_pairs(_version)
      [
        CodePair.new(62, @color)
      ]
    end

    def try_set_code_pair(code_pair)
      case code_pair.code
      when 62
        @color = code_pair.value
      else
        super(code_pair)
      end
    end

    def self.from_code_pair_reader(code_pair_reader)
      layer = Layer.new("0", 7)

      loop do
        break if code_pair_reader.current.nil? || code_pair_reader.current.code == 0

        layer.try_set_code_pair(code_pair_reader.current)
        code_pair_reader.move_next
      end

      return layer
    end
  end
end
