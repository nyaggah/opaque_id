---
layout: default
title: Configuration
nav_order: 5
description: "Complete configuration guide with all options and examples"
permalink: /configuration/
---

# Configuration

OpaqueId provides extensive configuration options to customize ID generation for your specific needs. This guide covers all available configuration options with practical examples.

- TOC
  {:toc}

## Model-Level Configuration

Configure OpaqueId on a per-model basis using class-level settings.

### Basic Configuration

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Custom column name
  self.opaque_id_column = :public_id

  # Custom length (default: 18)
  self.opaque_id_length = 15

  # Custom alphabet (default: SLUG_LIKE_ALPHABET)
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

  # Require letter start (default: false)
  self.opaque_id_require_letter_start = true

  # Max retry attempts (default: 3)
  self.opaque_id_max_retry = 5

  # Characters to purge from generated IDs (default: [])
  self.opaque_id_purge_chars = ['0', 'O', 'l', 'I']
end
```

### Configuration Options Reference

| Option                           | Type    | Default              | Description                                   |
| -------------------------------- | ------- | -------------------- | --------------------------------------------- |
| `opaque_id_column`               | Symbol  | `:opaque_id`         | Column name for storing the opaque ID         |
| `opaque_id_length`               | Integer | `18`                 | Length of generated IDs                       |
| `opaque_id_alphabet`             | String  | `SLUG_LIKE_ALPHABET` | Character set for ID generation               |
| `opaque_id_require_letter_start` | Boolean | `false`              | Require IDs to start with a letter            |
| `opaque_id_max_retry`            | Integer | `3`                  | Maximum retry attempts for collision handling |
| `opaque_id_purge_chars`          | Array   | `[]`                 | Characters to exclude from generated IDs      |

## Global Configuration

Configure OpaqueId globally using an initializer.

### Basic Global Configuration

```ruby
# config/initializers/opaque_id.rb
OpaqueId.configure do |config|
  config.default_length = 15
  config.default_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

### Advanced Global Configuration

```ruby
# config/initializers/opaque_id.rb
OpaqueId.configure do |config|
  # Set default values for all models
  config.default_length = 21
  config.default_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

  # Configure specific models
  config.models = {
    'User' => {
      length: 15,
      alphabet: OpaqueId::STANDARD_ALPHABET,
      require_letter_start: true
    },
    'Order' => {
      length: 12,
      alphabet: OpaqueId::ALPHANUMERIC_ALPHABET,
      column: :public_id
    }
  }
end
```

## Alphabet Configuration

### Built-in Alphabets

#### SLUG_LIKE_ALPHABET (Default)

```ruby
# Characters: 0-9, a-z (36 characters)
# Use case: URL-safe, double-click selectable, no confusing characters
# Example output: "izkpm55j334u8x9y2a"

class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::SLUG_LIKE_ALPHABET
end
```

#### ALPHANUMERIC_ALPHABET

```ruby
# Characters: A-Z, a-z, 0-9 (62 characters)
# Use case: General purpose, URL-safe
# Example output: "V1StGXR8Z5jdHi6BmyT"

class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end
```

#### STANDARD_ALPHABET

```ruby
# Characters: A-Z, a-z, 0-9, -, _ (64 characters)
# Use case: Fastest generation, URL-safe
# Example output: "V1StGXR8_Z5jdHi6B-myT"

class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

### Custom Alphabets

#### Numeric Only

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Generate numeric-only IDs
  self.opaque_id_alphabet = "0123456789"
  self.opaque_id_length = 10
end

# Example output: "1234567890"
```

#### Hexadecimal

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Generate hexadecimal IDs
  self.opaque_id_alphabet = "0123456789abcdef"
  self.opaque_id_length = 16
end

# Example output: "a1b2c3d4e5f67890"
```

#### URL-Safe Characters

```ruby
class Article < ApplicationRecord
  include OpaqueId::Model

  # Generate URL-safe IDs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  self.opaque_id_length = 8
end

# Example output: "V1StGXR8"
```

#### Base64-Style

```ruby
class Document < ApplicationRecord
  include OpaqueId::Model

  # Generate Base64-style IDs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  self.opaque_id_length = 12
end

# Example output: "V1StGXR8_Z5j"
```

## Length Configuration

### Short IDs (8-12 characters)

```ruby
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  # Short IDs for URLs
  self.opaque_id_length = 8
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Example output: "V1StGXR8"
```

### Medium IDs (15-21 characters)

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Standard length for general use
  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Example output: "V1StGXR8_Z5jdHi6B-myT"
```

### Long IDs (32+ characters)

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Long IDs for sensitive data
  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Example output: "V1StGXR8_Z5jdHi6B-myT1234567890"
```

## Column Name Configuration

### Custom Column Names

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Use a different column name
  self.opaque_id_column = :public_id
end

# Now the methods use the custom column name
user = User.create!(name: "John Doe")
puts user.public_id
# => "izkpm55j334u8x9y2a"

user = User.find_by_public_id("izkpm55j334u8x9y2a")
```

### Multiple Column Names

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_column = :public_id
end

class Order < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_column = :order_number
end

class Product < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_column = :sku
end
```

## Validation Configuration

### Letter Start Requirement

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Require IDs to start with a letter
  self.opaque_id_require_letter_start = true
end

# This will retry until it generates an ID starting with a letter
user = User.create!(name: "John Doe")
puts user.opaque_id
# => "izkpm55j334u8x9y2a" (starts with 'i')
```

### Character Purging

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Exclude confusing characters
  self.opaque_id_purge_chars = ['0', 'O', 'l', 'I']
end

# Generated IDs will not contain these characters
user = User.create!(name: "John Doe")
puts user.opaque_id
# => "izkpm55j334u8x9y2a" (no '0', 'O', 'l', 'I')
```

## Collision Handling Configuration

### Retry Attempts

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Increase retry attempts for high-volume applications
  self.opaque_id_max_retry = 10
end
```

### Custom Collision Handling

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  private

  def set_opaque_id
    retries = 0
    max_retries = opaque_id_max_retry

    begin
      self.opaque_id = generate_opaque_id
    rescue OpaqueId::GenerationError => e
      retries += 1
      if retries < max_retries
        retry
      else
        # Custom fallback logic
        self.opaque_id = generate_fallback_id
      end
    end
  end

  def generate_fallback_id
    # Fallback generation method
    "fallback_#{SecureRandom.hex(10)}"
  end
end
```

## Environment-Specific Configuration

### Development Environment

```ruby
# config/environments/development.rb
if Rails.env.development?
  OpaqueId.configure do |config|
    # Shorter IDs for development
    config.default_length = 8
    config.default_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  end
end
```

### Production Environment

```ruby
# config/environments/production.rb
if Rails.env.production?
  OpaqueId.configure do |config|
    # Longer IDs for production
    config.default_length = 21
    config.default_alphabet = OpaqueId::STANDARD_ALPHABET
  end
end
```

### Test Environment

```ruby
# config/environments/test.rb
if Rails.env.test?
  OpaqueId.configure do |config|
    # Predictable IDs for testing
    config.default_length = 10
    config.default_alphabet = "0123456789"
  end
end
```

## Configuration Examples by Use Case

### E-commerce Application

```ruby
# Orders - short, numeric IDs
class Order < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :order_number
  self.opaque_id_length = 8
  self.opaque_id_alphabet = "0123456789"
end

# Products - medium, alphanumeric IDs
class Product < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :sku
  self.opaque_id_length = 12
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Users - standard IDs
class User < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

### API Development

```ruby
# API Keys - long, secure IDs
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
  self.opaque_id_require_letter_start = true
end

# API Tokens - medium, URL-safe IDs
class ApiToken < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :token
  self.opaque_id_length = 24
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end
```

### Content Management

```ruby
# Articles - short, URL-friendly IDs
class Article < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :slug
  self.opaque_id_length = 8
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
end

# Comments - standard IDs
class Comment < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end
```

## Configuration Validation

### Validate Configuration

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  validate :validate_opaque_id_configuration

  private

  def validate_opaque_id_configuration
    if opaque_id_length < 8
      errors.add(:base, "Opaque ID length must be at least 8 characters")
    end

    if opaque_id_alphabet.size < 16
      errors.add(:base, "Opaque ID alphabet must have at least 16 characters")
    end

    if opaque_id_max_retry < 1
      errors.add(:base, "Opaque ID max retry must be at least 1")
    end
  end
end
```

### Configuration Testing

```ruby
# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "opaque_id configuration is valid" do
    user = User.new(name: "Test User")

    assert user.valid?
    assert_equal 18, user.class.opaque_id_length
    assert_equal OpaqueId::SLUG_LIKE_ALPHABET, user.class.opaque_id_alphabet
  end

  test "opaque_id generation works with custom configuration" do
    user = User.new(name: "Test User")
    user.class.opaque_id_length = 15
    user.class.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

    user.save!

    assert_equal 15, user.opaque_id.length
    assert user.opaque_id.match?(/\A[A-Za-z0-9_-]+\z/)
  end
end
```

## Best Practices

### 1. Choose Appropriate Length

- **Short IDs (8-12)**: Public URLs, user-facing identifiers
- **Medium IDs (15-21)**: General purpose, internal references
- **Long IDs (32+)**: Sensitive data, API keys, tokens

### 2. Select Suitable Alphabets

- **SLUG_LIKE_ALPHABET** (default): URL-safe, double-click selectable, no confusing characters
- **ALPHANUMERIC_ALPHABET**: General purpose, URL-safe
- **STANDARD_ALPHABET**: Fastest generation, URL-safe
- **Custom alphabets**: Specific requirements (numeric, hexadecimal, etc.)

### 3. Configure Collision Handling

- **Low volume**: Default retry attempts (3)
- **High volume**: Increase retry attempts (5-10)
- **Critical systems**: Implement custom fallback logic

### 4. Use Environment-Specific Settings

- **Development**: Shorter IDs for easier testing
- **Production**: Longer IDs for better security
- **Test**: Predictable IDs for consistent testing

## Next Steps

Now that you understand configuration options:

1. **Explore [Alphabets](alphabets.md)** for detailed alphabet information
2. **Check out [Use Cases](use-cases.md)** for real-world configuration examples
3. **Review [Performance](performance.md)** for configuration optimization tips
4. **Read [API Reference](api-reference.md)** for complete configuration documentation
5. **Learn about [Algorithms](algorithms.md)** for technical implementation details
6. **Understand [Security](security.md)** for security considerations
