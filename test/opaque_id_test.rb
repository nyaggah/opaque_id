# frozen_string_literal: true

require 'test_helper'

class OpaqueIdTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OpaqueId::VERSION
  end

  def test_generate_with_default_parameters
    id = OpaqueId.generate
    assert_equal 21, id.length
    assert_match(/\A[A-Za-z0-9]+\z/, id)
  end

  def test_generate_with_custom_size
    id = OpaqueId.generate(size: 10)
    assert_equal 10, id.length
    assert_match(/\A[A-Za-z0-9]+\z/, id)
  end

  def test_generate_with_custom_alphabet
    custom_alphabet = 'ABCDEF'
    id = OpaqueId.generate(size: 5, alphabet: custom_alphabet)
    assert_equal 5, id.length
    assert_match(/\A[ABCDEF]+\z/, id)
  end

  def test_generate_with_standard_alphabet
    id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
    assert_equal 21, id.length
    assert_match(/\A[A-Za-z0-9_-]+\z/, id)
  end

  def test_generate_returns_different_ids
    id1 = OpaqueId.generate
    id2 = OpaqueId.generate
    refute_equal id1, id2
  end

  def test_generate_with_zero_size_raises_error
    assert_raises(OpaqueId::ConfigurationError) do
      OpaqueId.generate(size: 0)
    end
  end

  def test_generate_with_negative_size_raises_error
    assert_raises(OpaqueId::ConfigurationError) do
      OpaqueId.generate(size: -1)
    end
  end

  def test_generate_with_empty_alphabet_raises_error
    assert_raises(OpaqueId::ConfigurationError) do
      OpaqueId.generate(alphabet: '')
    end
  end

  def test_generate_with_nil_alphabet_raises_error
    assert_raises(OpaqueId::ConfigurationError) do
      OpaqueId.generate(alphabet: nil)
    end
  end

  def test_alphabet_constants_are_defined
    assert_equal 64, OpaqueId::STANDARD_ALPHABET.length
    assert_equal 62, OpaqueId::ALPHANUMERIC_ALPHABET.length
  end

  def test_standard_alphabet_contains_expected_characters
    expected_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
    assert_equal expected_chars, OpaqueId::STANDARD_ALPHABET
  end

  def test_alphanumeric_alphabet_contains_expected_characters
    expected_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    assert_equal expected_chars, OpaqueId::ALPHANUMERIC_ALPHABET
  end

  def test_statistical_uniformity_with_64_character_alphabet
    # Test that 64-character alphabet uses fast path
    alphabet = OpaqueId::STANDARD_ALPHABET
    assert_equal 64, alphabet.length

    # Generate many IDs and check character distribution
    char_counts = Hash.new(0)
    total_chars = 0

    1000.times do
      id = OpaqueId.generate(size: 10, alphabet: alphabet)
      id.each_char do |char|
        char_counts[char] += 1
        total_chars += 1
      end
    end

    # Each character should appear roughly equally (within 30% tolerance)
    expected_count = total_chars / 64.0
    char_counts.each_value do |count|
      assert_in_delta expected_count, count, expected_count * 0.3,
                      'Character distribution should be roughly uniform'
    end
  end

  def test_statistical_uniformity_with_custom_alphabet
    # Test rejection sampling with non-power-of-2 alphabet
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' # 26 characters
    char_counts = Hash.new(0)
    total_chars = 0

    1000.times do
      id = OpaqueId.generate(size: 10, alphabet: alphabet)
      id.each_char do |char|
        char_counts[char] += 1
        total_chars += 1
      end
    end

    # Each character should appear roughly equally (within 25% tolerance for smaller sample)
    expected_count = total_chars / 26.0
    char_counts.each_value do |count|
      assert_in_delta expected_count, count, expected_count * 0.25,
                      'Character distribution should be roughly uniform with rejection sampling'
    end
  end

  def test_performance_benchmark_64_character_alphabet
    alphabet = OpaqueId::STANDARD_ALPHABET
    start_time = Time.now

    1000.times do
      OpaqueId.generate(size: 21, alphabet: alphabet)
    end

    elapsed = Time.now - start_time
    # Should be very fast for 64-character alphabet (fast path)
    assert elapsed < 0.1, '64-character alphabet generation should be fast (< 0.1s for 1000 IDs)'
  end

  def test_performance_benchmark_custom_alphabet
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' # 26 characters
    start_time = Time.now

    1000.times do
      OpaqueId.generate(size: 21, alphabet: alphabet)
    end

    elapsed = Time.now - start_time
    # Should still be reasonably fast even with rejection sampling
    assert elapsed < 0.5, 'Custom alphabet generation should be reasonably fast (< 0.5s for 1000 IDs)'
  end

  def test_error_classes_are_defined
    assert OpaqueId::Error < StandardError
    assert OpaqueId::ConfigurationError < OpaqueId::Error
    assert OpaqueId::GenerationError < OpaqueId::Error
  end

  def test_generate_with_very_large_size
    # Test that large sizes work (though not recommended in practice)
    id = OpaqueId.generate(size: 1000)
    assert_equal 1000, id.length
    assert_match(/\A[A-Za-z0-9]+\z/, id)
  end

  def test_generate_with_single_character_alphabet
    # Edge case: single character alphabet
    id = OpaqueId.generate(size: 5, alphabet: 'A')
    assert_equal 'AAAAA', id
  end

  def test_generate_with_two_character_alphabet
    # Edge case: two character alphabet
    alphabet = 'AB'
    id = OpaqueId.generate(size: 10, alphabet: alphabet)
    assert_equal 10, id.length
    assert_match(/\A[AB]+\z/, id)
  end
end
