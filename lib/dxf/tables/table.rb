# frozen_string_literal: true

module Dxf
  # Represents a table in a DXF file.
  class Table
    attr_reader :kind
    attr_accessor :items

    def initialize(kind)
      @kind = kind
      @items = []
    end

    def code_pairs(version)
      code_pairs = [
        CodePair.new(0, "TABLE"),
        CodePair.new(2, @kind),
        CodePair.new(70, @items.length)
      ]

      @items.each do |table_item|
        code_pairs += table_item.code_pairs(version)
      end

      code_pairs << CodePair.new(0, "ENDTAB")
      code_pairs
    end
  end
end
