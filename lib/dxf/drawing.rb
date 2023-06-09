# frozen_string_literal: true

require_relative "point"
require_relative "code_pair"
require_relative "code_pair_reader"
require_relative "entities"
require_relative "header"
require_relative "tables"

module Dxf
  # Represents a DXF drawing.
  class Drawing
    attr_accessor :header, :entities

    def initialize
      @header = Header.new
      @entities = []
      @layer_table = Table.new("LAYER")
      @layer_table.items << Layer.new("0", 7)
    end

    def clear
      @entities = []
      @layer_table = Table.new("LAYER")
    end

    def layers
      @layer_table.items
    end

    def code_pairs
      @header.code_pairs +
        table_code_pairs(@header.version) +
        entity_code_pairs(@header.version) +
        [CodePair.new(0, "EOF")]
    end

    def to_s
      code_pairs.map(&:to_ascii).join
    end

    def save(path)
      File.write(path, to_s)
    end

    def self.from_code_pairs(code_pairs)
      drawing = Drawing.new
      drawing.clear
      code_pair_reader = CodePairReader.new(code_pairs)

      loop do
        break if code_pair_reader.current.eof?

        code_pair_reader.expect(0, "SECTION")
        code_pair_reader.move_next
        code_pair_reader.expect(2)
        section_name = code_pair_reader.current.value
        code_pair_reader.move_next
        case section_name
        when "HEADER"
          drawing.header = Header.from_code_pair_reader(code_pair_reader)
        when "TABLES"
          drawing.read_tables(code_pair_reader)
        when "ENTITIES"
          drawing.entities = Entity.section_from_code_pair_reader(code_pair_reader)
        else
          # skip unknown section
          code_pair_reader.move_next_until(0, "ENDSEC")
        end

        code_pair_reader.expect(0, "ENDSEC")
        code_pair_reader.move_next
      end

      drawing
    end

    def self.parse(text)
      code_pairs = CodePair.pairs_from_text(text)
      Drawing.from_code_pairs(code_pairs)
    end

    def read_tables(code_pair_reader)
      loop do
        code_pair_reader.print_status("entering read table loop")
        code_pair_reader.expect(0, "TABLE")
        code_pair_reader.move_next
        code_pair_reader.expect(2)
        table_type = code_pair_reader.current.value
        code_pair_reader.move_next
        code_pair_reader.print_status("trying to read table type #{table_type}")
        case table_type
        when "LAYER"
          code_pair_reader.print_status("found layer table start")
          read_layers(code_pair_reader)
        else
          # skip unknown
          code_pair_reader.move_next_until(0, "ENDTAB")
          code_pair_reader.print_status("skipped unknown table #{table_type}")
        end

        code_pair_reader.expect(0, "ENDTAB")
        code_pair_reader.move_next

        break if code_pair_reader.current.endsec?
      end
    end

    def read_layers(code_pair_reader)
      loop do
        code_pair_reader.expect(0)
        break if code_pair_reader.current.endtab?

        code_pair_reader.expect(0, "LAYER")
        code_pair_reader.move_next
        code_pair_reader.print_status("found layer definition start")
        layer = Layer.from_code_pair_reader(code_pair_reader)
        @layer_table.items << layer
        break if code_pair_reader.current.endtab?
      end
    end

    private

    def table_code_pairs(version)
      code_pairs = [
        CodePair.new(0, "SECTION"),
        CodePair.new(2, "TABLES")
      ]

      code_pairs += @layer_table.code_pairs(version)

      code_pairs << CodePair.new(0, "ENDSEC")
    end

    def entity_code_pairs(version)
      code_pairs = [
        CodePair.new(0, "SECTION"),
        CodePair.new(2, "ENTITIES")
      ]

      @entities.each do |entity|
        code_pairs += entity.code_pairs(version)
      end

      code_pairs << CodePair.new(0, "ENDSEC")
    end
  end
end
