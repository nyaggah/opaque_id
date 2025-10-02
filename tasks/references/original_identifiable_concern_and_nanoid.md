This is the original functionality we are replicating and enhancing. typically implemented as a concern in a Model via `include Identifiable`

```ruby
require "nanoid"

# generate a public_id (nanoid) when creating new records
# unique URL-friendly ID that'll prevent exposing incremental db ids where
# we otherwise can't or don't want to use friendly_ids e.g. in URLs and APIs
#
# https://planetscale.com/blog/why-we-chose-nanoids-for-planetscales-api#generating-nanoids-in-rails
# https://maful.web.id/posts/how-i-use-nano-id-in-rails/
# https://zelark.github.io/nano-id-cc/
module Identifiable
  extend ActiveSupport::Concern

  included do
    before_create :set_public_id
  end

  PUBLIC_ID_ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"
  PUBLIC_ID_LENGTH = 18
  MAX_RETRY = 1000

  PUBLIC_ID_REGEX = /[#{PUBLIC_ID_ALPHABET}]{#{PUBLIC_ID_LENGTH}}\z/

  class_methods do
    def generate_nanoid(alphabet: PUBLIC_ID_ALPHABET, size: PUBLIC_ID_LENGTH)
      Nanoid.generate(size:, alphabet:)
    end
  end

  def set_public_id
    return if public_id.present?

    MAX_RETRY.times do
      self.public_id = generate_public_id
      return unless self.class.where(public_id:).exists?
    end
    raise "Failed to generate a unique public id after #{MAX_RETRY} attempts"
  end

  def generate_public_id
    self.class.generate_nanoid(alphabet: PUBLIC_ID_ALPHABET)
  end
end
```

The original nanoid.rb is below

```ruby
require 'securerandom'

module Nanoid
  SAFE_ALPHABET = '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'.freeze

  def self.generate(size: 21, alphabet: SAFE_ALPHABET, non_secure: false)
    return non_secure_generate(size: size, alphabet: alphabet) if non_secure

    return simple_generate(size: size) if alphabet == SAFE_ALPHABET

    complex_generate(size: size, alphabet: alphabet)
  end

  private

  def self.simple_generate(size:)
    bytes = random_bytes(size)

    (0...size).reduce('') do |acc, i|
      acc << SAFE_ALPHABET[bytes[i] & 63]
    end
  end

  def self.complex_generate(size:, alphabet:)
    alphabet_size = alphabet.size
    mask = (2 << Math.log(alphabet_size - 1) / Math.log(2)) - 1
    step = (1.6 * mask * size / alphabet_size).ceil

    id = ''

    loop do
      bytes = random_bytes(size)
      (0...step).each do |idx|
        byte = bytes[idx] & mask
        character = byte && alphabet[byte]
        if character
          id << character
          return id if id.size == size
        end
      end
    end
  end

  def self.non_secure_generate(size:, alphabet:)
    alphabet_size = alphabet.size

    id = ''

    size.times do
      id << alphabet[(Random.rand * alphabet_size).floor]
    end

    id
  end

  def self.random_bytes(size)
    SecureRandom.random_bytes(size).bytes
  end
end
```
