# frozen_string_literal: true

module Dxf
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

    def code_pairs(version)
      code_pairs = [
        CodePair.new(0, @type),
        CodePair.new(8, @layer)
      ]

      code_pairs += specific_code_pairs(version)
      code_pairs
    end

    def self.section_from_code_pair_reader(code_pair_reader)
      entities = []

      until code_pair_reader.current.endsec?
        code_pair_reader.expect(0)
        entity_type = code_pair_reader.current.value
        code_pair_reader.move_next

        class_type = class_from_entity_type(entity_type)
        if class_type.nil?
          # skip unknown entity
          code_pair_reader.move_next_until(0)
        else
          entity = class_type.new
          until code_pair_reader.current.code == 0
            entity.try_set_code_pair(code_pair_reader.current)
            code_pair_reader.move_next
          end
          entities << entity
        end
      end

      return entities
    end

    def self.class_from_entity_type(entity_type)
      case entity_type
      when "ARC"
        Arc
      when "LINE"
        Line
      end
    end
  end
end
