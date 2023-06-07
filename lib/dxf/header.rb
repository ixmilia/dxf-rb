# frozen_string_literal: true

module AcadVersion
  R12 = 12
  R14 = 14
end

# Represents the header variables of a DXF file.
class Header
  attr_accessor :version

  def initialize
    @version = AcadVersion::R12
  end

  def code_pairs
    [
      CodePair.new(0, "SECTION"),
      CodePair.new(2, "HEADER"),
      CodePair.new(9, "$ACADVER"),
      CodePair.new(1, string_from_acad_version(@version)),
      CodePair.new(0, "ENDSEC")
    ]
  end

  def self.from_code_pairs(code_pairs, start_index)
    header = Header.new
    next_index = start_index
    last_variable_name = nil
    code_pairs[start_index..].each_with_index do |code_pair, index|
      next_index = start_index + index + 1

      break if code_pair.code == 0 && code_pair.value == "ENDSEC"

      if code_pair.code == 9
        last_variable_name = code_pair.value
      else
        header.set_header_variable(last_variable_name, code_pair.value)
      end
    end

    return header, next_index
  end

  def set_header_variable(variable, value)
    case variable
    when "$ACADVER"
      @version = acad_version_from_string(value)
    end
  end

  private

  def acad_version_from_string(acad_version)
    case acad_version
    when "AC1009"
      AcadVersion::R12
    when "AC1014"
      AcadVersion::R14
    else
      raise "Unknown acad version: #{acad_version}"
    end
  end

  def string_from_acad_version(acad_version)
    case acad_version
    when AcadVersion::R12
      "AC1009"
    when AcadVersion::R14
      "AC1014"
    else
      raise "Unknown acad version: #{acad_version}"
    end
  end
end
