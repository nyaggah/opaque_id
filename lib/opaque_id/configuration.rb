# frozen_string_literal: true

module OpaqueId
  class Configuration
    attr_accessor :default_length, :default_alphabet, :default_column,
                  :default_require_letter_start, :default_purge_chars, :default_max_retry

    def initialize
      @default_length = 18
      @default_alphabet = OpaqueId::SLUG_LIKE_ALPHABET
      @default_column = :opaque_id
      @default_require_letter_start = false
      @default_purge_chars = []
      @default_max_retry = 3
    end
  end
end
