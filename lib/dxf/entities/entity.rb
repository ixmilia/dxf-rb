# frozen_string_literal: true

# Represents a graphical entity.
class Entity
  attr_accessor :layer

  def initialize
    @layer = "0"
  end

  def try_set_code_pair(code_pair)
    case code_pair.code
    when 8
      @layer = code_pair.value
    end
  end

  def self.section_from_code_pairs(code_pairs, start_index)
    next_index = start_index
    entities = []

    code_pairs[start_index..].each_with_index do |code_pair, index|
      next_index = start_index + index + 1

      break if code_pair.code == 0 && code_pair.value == "ENDSEC"
      next if code_pair.code != 0

      case code_pair.value
      when "LINE"
        line, next_index = Line.from_code_pairs(code_pairs, next_index)
        entities << line
      end
    end

    return entities, next_index
  end
end
