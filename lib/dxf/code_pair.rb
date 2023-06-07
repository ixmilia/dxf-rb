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

  def to_s
    "[#{@code}/#{@value}]"
  end

  private

  def self.parse_value(code, value)
    # switch based on the code
    case code
    when 0..9
      value.chomp("\r")
    when 10..59
      value.strip.to_f
    else
      raise "Unknown code: #{code}"
    end
  end

end
