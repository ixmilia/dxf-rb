# frozen_string_literal: true

# Represents a DXF drawing.
class Drawing
  attr_accessor :header, :entities

  def initialize
    @header = Header.new
    @entities = []
  end

  def code_pairs
    @header.code_pairs +
      entity_code_pairs(@header.version) +
      [CodePair.new(0, "EOF")]
  end

  def to_s
    "#{code_pairs.map { |code_pair| "#{code_pair.code}\r\n#{code_pair.value}" }.join("\r\n")}\r\n"
  end

  def self.from_code_pairs(code_pairs)
    drawing = Drawing.new
    next_index = 0
    code_pairs.each_with_index do |code_pair, index|
      next if index < next_index
      next if code_pair.code != 0

      case code_pair.value
      when "SECTION"
        section_name = code_pairs[index + 1].value
        case section_name
        when "HEADER"
          drawing.header, next_index = Header.from_code_pairs(code_pairs, index + 2)
        when "ENTITIES"
          drawing.entities, next_index = Entity.section_from_code_pairs(code_pairs, index + 2)
        else
          # skip unknown sections
          next_index += 1 while code_pairs[next_index].value != "ENDSEC"
        end
      end
    end

    drawing
  end

  def self.parse(text)
    code_pairs = CodePair.pairs_from_text(text)
    Drawing.from_code_pairs(code_pairs)
  end

  private

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
