# frozen_string_literal: true

module Dxf
  # Represents a table item in a DXF file.
  class TableItem
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def code_pairs(version)
      code_pairs = [
        CodePair.new(0, @type),
        CodePair.new(2, @name)
      ]

      code_pairs += specific_code_pairs(version)
      code_pairs
    end

    def try_set_code_pair(code_pair)
      case code_pair.code
      when 2
        @name = code_pair.value
      end
    end
  end
end
