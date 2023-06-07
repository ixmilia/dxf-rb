# frozen_string_literal: true

require "test_helper"

include Dxf

class TestDxf < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Dxf::VERSION
  end
end
