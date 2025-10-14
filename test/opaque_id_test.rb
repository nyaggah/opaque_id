# frozen_string_literal: true

require 'test_helper'

class OpaqueIdTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OpaqueId::VERSION
  end

  def test_generate_with_default_parameters
    id = OpaqueId.generate
    assert_equal 18, id.length
    assert_match(/\A[0-9a-z]+\z/, id)
  end

  def test_generate_with_custom_size
    id = OpaqueId.generate(size: 10)
    assert_equal 10, id.length
    assert_match(/\A[0-9a-z]+\z/, id)
  end

  def test_generate_with_custom_alphabet
    custom_alphabet = 'ABCDEF'
    id = OpaqueId.generate(size: 5, alphabet: custom_alphabet)
    assert_equal 5, id.length
    assert_match(/\A[ABCDEF]+\z/, id)
  end

  def test_generate_with_standard_alphabet
    id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
    assert_equal 18, id.length
    assert_match(/\A[A-Za-z0-9_-]+\z/, id)
  end

  def test_generate_returns_different_ids
    id1 = OpaqueId.generate
    id2 = OpaqueId.generate
    refute_equal id1, id2
    # Both should use default slug-like alphabet
    assert_match(/\A[0-9a-z]+\z/, id1)
    assert_match(/\A[0-9a-z]+\z/, id2)
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
    assert_equal 36, OpaqueId::SLUG_LIKE_ALPHABET.length
    assert_equal 64, OpaqueId::STANDARD_ALPHABET.length
    assert_equal 62, OpaqueId::ALPHANUMERIC_ALPHABET.length
  end

  def test_standard_alphabet_contains_expected_characters
    expected_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
    assert_equal expected_chars, OpaqueId::STANDARD_ALPHABET
  end

  def test_slug_like_alphabet_contains_expected_characters
    expected_chars = '0123456789abcdefghijklmnopqrstuvwxyz'
    assert_equal expected_chars, OpaqueId::SLUG_LIKE_ALPHABET
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

    # Increase sample size for better statistical reliability
    5000.times do
      id = OpaqueId.generate(size: 10, alphabet: alphabet)
      id.each_char do |char|
        char_counts[char] += 1
        total_chars += 1
      end
    end

    # Each character should appear roughly equally (within 50% tolerance for CI stability)
    expected_count = total_chars / 64.0
    char_counts.each_value do |count|
      assert_in_delta expected_count, count, expected_count * 0.5,
                      'Character distribution should be roughly uniform'
    end

    # Additional check: ensure all characters appear at least once
    assert_equal 64, char_counts.size, 'All 64 characters should appear in the sample'
  end

  def test_statistical_uniformity_with_custom_alphabet
    # Test rejection sampling with non-power-of-2 alphabet
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' # 26 characters
    char_counts = Hash.new(0)
    total_chars = 0

    # Increase sample size for better statistical reliability
    3000.times do
      id = OpaqueId.generate(size: 10, alphabet: alphabet)
      id.each_char do |char|
        char_counts[char] += 1
        total_chars += 1
      end
    end

    # Each character should appear roughly equally (within 40% tolerance for CI stability)
    expected_count = total_chars / 26.0
    char_counts.each_value do |count|
      assert_in_delta expected_count, count, expected_count * 0.4,
                      'Character distribution should be roughly uniform with rejection sampling'
    end

    # Additional check: ensure all characters appear at least once
    assert_equal 26, char_counts.size, 'All 26 characters should appear in the sample'
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
    assert_match(/\A[0-9a-z]+\z/, id)
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

  # Configuration tests
  def test_configuration_defaults
    OpaqueId.reset_configuration!

    config = OpaqueId.configuration
    assert_equal 18, config.default_length
    assert_equal OpaqueId::SLUG_LIKE_ALPHABET, config.default_alphabet
    assert_equal :opaque_id, config.default_column
    assert_equal false, config.default_require_letter_start
    assert_equal [], config.default_purge_chars
    assert_equal 3, config.default_max_retry
  end

  def test_configure_method
    OpaqueId.reset_configuration!

    OpaqueId.configure do |config|
      config.default_length = 21
      config.default_alphabet = OpaqueId::STANDARD_ALPHABET
      config.default_column = :public_id
      config.default_require_letter_start = true
      config.default_purge_chars = %w[0 O]
      config.default_max_retry = 5
    end

    config = OpaqueId.configuration
    assert_equal 21, config.default_length
    assert_equal OpaqueId::STANDARD_ALPHABET, config.default_alphabet
    assert_equal :public_id, config.default_column
    assert_equal true, config.default_require_letter_start
    assert_equal %w[0 O], config.default_purge_chars
    assert_equal 5, config.default_max_retry
  end

  def test_reset_configuration
    # Set custom configuration
    OpaqueId.configure do |config|
      config.default_length = 25
      config.default_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
      config.default_column = :public_id
      config.default_require_letter_start = true
      config.default_purge_chars = %w[0 O]
      config.default_max_retry = 5
    end

    # Verify it's set
    assert_equal 25, OpaqueId.configuration.default_length

    # Reset and verify defaults
    OpaqueId.reset_configuration!
    assert_equal 18, OpaqueId.configuration.default_length
    assert_equal OpaqueId::SLUG_LIKE_ALPHABET, OpaqueId.configuration.default_alphabet
    assert_equal :opaque_id, OpaqueId.configuration.default_column
    assert_equal false, OpaqueId.configuration.default_require_letter_start
    assert_equal [], OpaqueId.configuration.default_purge_chars
    assert_equal 3, OpaqueId.configuration.default_max_retry
  end

  def test_model_uses_global_configuration
    OpaqueId.reset_configuration!

    # Set global configuration
    OpaqueId.configure do |config|
      config.default_length = 21
      config.default_alphabet = OpaqueId::STANDARD_ALPHABET
      config.default_column = :public_id
      config.default_require_letter_start = true
      config.default_purge_chars = %w[0 O]
      config.default_max_retry = 5
    end

    # Create a test model class that inherits from ActiveRecord::Base
    test_model_class = Class.new(ActiveRecord::Base) do
      include OpaqueId::Model

      self.table_name = 'test_models'
    end

    # Verify model uses global defaults
    assert_equal 21, test_model_class.opaque_id_length
    assert_equal OpaqueId::STANDARD_ALPHABET, test_model_class.opaque_id_alphabet
    assert_equal :public_id, test_model_class.opaque_id_column
    assert_equal true, test_model_class.opaque_id_require_letter_start
    assert_equal %w[0 O], test_model_class.opaque_id_purge_chars
    assert_equal 5, test_model_class.opaque_id_max_retry
  end

  def test_model_override_takes_priority
    OpaqueId.reset_configuration!

    # Set global configuration
    OpaqueId.configure do |config|
      config.default_length = 21
      config.default_alphabet = OpaqueId::STANDARD_ALPHABET
    end

    # Create a test model class with overrides
    test_model_class = Class.new(ActiveRecord::Base) do
      include OpaqueId::Model

      self.table_name = 'test_models'
      self.opaque_id_length = 15
      self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
    end

    # Verify model overrides take priority
    assert_equal 15, test_model_class.opaque_id_length
    assert_equal OpaqueId::ALPHANUMERIC_ALPHABET, test_model_class.opaque_id_alphabet
  end

  def test_configuration_persistence_across_models
    OpaqueId.reset_configuration!

    # Set global configuration
    OpaqueId.configure do |config|
      config.default_length = 12
      config.default_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
    end

    # Create multiple model classes
    model1 = Class.new(ActiveRecord::Base) do
      include OpaqueId::Model

      self.table_name = 'test_models_1'
    end
    model2 = Class.new(ActiveRecord::Base) do
      include OpaqueId::Model

      self.table_name = 'test_models_2'
    end

    # Both should use the same global configuration
    assert_equal 12, model1.opaque_id_length
    assert_equal 12, model2.opaque_id_length
    assert_equal OpaqueId::ALPHANUMERIC_ALPHABET, model1.opaque_id_alphabet
    assert_equal OpaqueId::ALPHANUMERIC_ALPHABET, model2.opaque_id_alphabet
  end
end
