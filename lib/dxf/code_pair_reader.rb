# frozen_string_literal: true

module Dxf
  # Represents a code/value pair reader.
  class CodePairReader
    attr_reader :code_pairs, :index

    def initialize(code_pairs, index = 0)
      @code_pairs = code_pairs
      @index = index
    end

    def current
      return nil if @index > @code_pairs.length

      @code_pairs[@index]
    end

    def move_next
      return unless @index < @code_pairs.length

      @index += 1
    end

    def move_next_until(code, value = nil)
      if value.nil?
        loop do
          break if current.code == code

          move_next
        end
      else
        loop do
          break if current.code == code && current.value == value

          move_next
        end
      end
    end

    def expect(code, value = nil)
      message = "Expected [#{code}/"
      message += value unless value.nil?
      message += "], found #{current}"

      if current.code != code
        # always fail if the code doesn't match
        raise message
      end

      # otherwise only fail if the value doesn't match
      return if value.nil? || current.value == value

      raise message
    end

    def print_status(message = nil)
      message = ": #{message}" unless message.nil?
      puts "offset: #{@index}, current: #{current}#{message}"
    end
  end
end
