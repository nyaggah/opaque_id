# frozen_string_literal: true

require 'securerandom'
require_relative 'opaque_id/version'
require_relative 'opaque_id/model'

module OpaqueId
  class Error < StandardError; end
  class GenerationError < Error; end
  class ConfigurationError < Error; end

  # Slug-like alphabet for URL-safe, double-click selectable IDs (36 characters)
  SLUG_LIKE_ALPHABET = '0123456789abcdefghijklmnopqrstuvwxyz'

  # Standard URL-safe alphabet (64 characters)
  STANDARD_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'

  # Alphanumeric alphabet (62 characters)
  ALPHANUMERIC_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

  class << self
    # Generate a cryptographically secure random ID
    def generate(size: 18, alphabet: SLUG_LIKE_ALPHABET)
      raise ConfigurationError, 'Size must be positive' unless size.positive?
      raise ConfigurationError, 'Alphabet cannot be empty' if alphabet.nil? || alphabet.empty?

      alphabet_size = alphabet.size

      # Handle edge case: single character alphabet
      return alphabet * size if alphabet_size == 1

      return generate_fast(size, alphabet) if alphabet_size == 64

      generate_unbiased(size, alphabet, alphabet_size)
    end

    private

    def generate_fast(size, alphabet)
      bytes = SecureRandom.random_bytes(size).bytes
      size.times.map { |i| alphabet[bytes[i] & 63] }.join
    end

    def generate_unbiased(size, alphabet, alphabet_size)
      mask = (2 << Math.log2(alphabet_size - 1).floor) - 1
      step = (1.6 * mask * size / alphabet_size).ceil
      id = String.new(capacity: size)

      loop do
        bytes = SecureRandom.random_bytes(step).bytes
        bytes.each do |byte|
          masked_byte = byte & mask
          if masked_byte < alphabet_size
            id << alphabet[masked_byte]
            return id if id.size == size
          end
        end
      end
    end
  end
end
