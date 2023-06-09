# frozen_string_literal: true

module Dxf
  # Represents a code/value pair.
  class CodePair
    attr_reader :code, :value

    def initialize(code, value)
      @code = code
      @value = value
    end

    def self.pairs_from_text(text)
      code_pairs = []
      lines = text.split("\n")
      lines.each_slice(2).map do |code, value|
        code = code.strip.to_i
        code_pairs << CodePair.new(code, parse_value(code, value))
      end

      code_pairs
    end

    def ==(other)
      self.class == other.class &&
        @code == other.code &&
        @value == other.value
    end

    def endsec?
      code == 0 && value == "ENDSEC"
    end

    def endtab?
      code == 0 && value == "ENDTAB"
    end

    def eof?
      code == 0 && value == "EOF"
    end

    def to_ascii
      "#{code.to_s.rjust(3)}\r\n#{value_to_ascii}\r\n"
    end

    def to_s
      "[#{@code}/#{@value}]"
    end

    def self.parse_value(code, value)
      # switch based on the code
      case type_from_code(code)
      when "string"
        value.chomp("\r")
      when "double"
        value.strip.to_f
      when "short", "int", "long"
        value.strip.to_i
      else
        raise "Unknown code: #{code}"
      end
    end

    def self.type_from_code(code)
      case code
      when 0..9, 300..309, 999, 1000..1009
        "string"
      when 10..59, 110..149, 210..239, 1010..1059
        "double"
      when 60..79, 170..179, 270..289, 1060..1070
        "short"
      when 90..99, 100..109, 1071
        "int"
      when 160..169
        "long"
      else
        raise "Unknown code: #{@code}"
      end
    end

    private

    def value_to_ascii
      case CodePair.type_from_code(@code)
      when "string"
        @value
      when "double"
        display = format("%.16f", @value).to_s.gsub(/0+$/, "")
        display += "0" if display[-1] == "."
        display
      when "short"
        @value.to_s.rjust(6)
      when "int"
        @value.to_s.rjust(9)
      when "long"
        @value.to_s
      else
        raise "Unknown code: #{@code}"
      end
    end
  end
end
