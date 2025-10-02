# frozen_string_literal: true

require 'test_helper'

class TestOpaqueId < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OpaqueId::VERSION
  end

  def test_it_has_core_functionality
    # Test that the core OpaqueId module is properly loaded
    assert_respond_to OpaqueId, :generate
    refute_nil OpaqueId::ALPHANUMERIC_ALPHABET
    refute_nil OpaqueId::STANDARD_ALPHABET
  end
end
