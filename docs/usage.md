---
layout: default
title: Usage
nav_order: 4
description: "Complete usage guide with standalone and ActiveRecord examples"
permalink: /usage/
---

# Usage

This guide covers all usage patterns for OpaqueId, from basic standalone generation to advanced ActiveRecord integration.

- TOC
  {:toc}

## Standalone ID Generation

OpaqueId can be used independently of ActiveRecord for generating secure, random IDs.

### Basic Usage

```ruby
# Generate a default opaque ID (18 characters, slug-like)
id = OpaqueId.generate
# => "izkpm55j334u8x9y2a"

# Generate multiple IDs
ids = 5.times.map { OpaqueId.generate }
# => ["izkpm55j334u8x9y2a", "k8jh2mn9pl3qr7st1v", ...]
```

### Custom Parameters

```ruby
# Custom length
id = OpaqueId.generate(size: 10)
# => "izkpm55j334u"

# Custom alphabet
id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT"

# Both custom length and alphabet
id = OpaqueId.generate(size: 15, alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B"
```

### Built-in Alphabets

```ruby
# Slug-like alphabet (default) - 0-9, a-z
id = OpaqueId.generate(alphabet: OpaqueId::SLUG_LIKE_ALPHABET)
# => "izkpm55j334u8x9y2a"

# Alphanumeric alphabet - A-Z, a-z, 0-9
id = OpaqueId.generate(alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
# => "V1StGXR8Z5jdHi6BmyT"

# Standard alphabet - A-Z, a-z, 0-9, -, _
id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT"
```

### Custom Alphabets

```ruby
# Numeric only
numeric_alphabet = "0123456789"
id = OpaqueId.generate(size: 8, alphabet: numeric_alphabet)
# => "12345678"

# Hexadecimal
hex_alphabet = "0123456789abcdef"
id = OpaqueId.generate(size: 16, alphabet: hex_alphabet)
# => "a1b2c3d4e5f67890"

# URL-safe characters
url_safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
id = OpaqueId.generate(size: 12, alphabet: url_safe)
# => "izkpm55j334u8x"
```

## ActiveRecord Integration

OpaqueId provides seamless integration with ActiveRecord models through the `OpaqueId::Model` concern.

### Basic Model Setup

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end
```

### Automatic ID Generation

```ruby
# Create a new user - opaque_id is automatically generated
user = User.create!(name: "John Doe", email: "john@example.com")
puts user.opaque_id
# => "izkpm55j334u8x9y2a"

# The ID is generated before the record is saved
user = User.new(name: "Jane Smith")
puts user.opaque_id
# => nil (not generated yet)

user.save!
puts user.opaque_id
# => "k8jh2mn9pl3qr7st1va" (generated on save)
```

### Finder Methods

```ruby
# Find by opaque_id (returns nil if not found)
user = User.find_by_opaque_id("izkpm55j334u8x9y2a")

# Find by opaque_id (raises exception if not found)
user = User.find_by_opaque_id!("izkpm55j334u8x9y2a")
# => ActiveRecord::RecordNotFound if not found

# Use in scopes
class User < ApplicationRecord
  include OpaqueId::Model

  scope :by_opaque_id, ->(id) { where(opaque_id: id) }
end

users = User.by_opaque_id("izkpm55j334u8x9y2a")
```

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

## Rails Generator

The Rails generator provides a convenient way to set up OpaqueId for your models.

### Basic Generator Usage

```bash
# Generate setup for a User model
rails generate opaque_id:install User
```

This creates:

- A migration to add the `opaque_id` column
- A unique index on the `opaque_id` column
- Includes the `OpaqueId::Model` concern in your model

### Custom Column Names

```bash
# Use a custom column name
rails generate opaque_id:install User --column-name=public_id
```

This will:

- Create a `public_id` column instead of `opaque_id`
- Add `self.opaque_id_column = :public_id` to your model

### Multiple Models

```bash
# Set up multiple models
rails generate opaque_id:install User
rails generate opaque_id:install Post --column-name=slug
rails generate opaque_id:install Comment
```

## Real-World Examples

### E-commerce Application

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Use shorter IDs for orders
  self.opaque_id_length = 12
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Create an order
order = Order.create!(user_id: 1, total: 99.99)
puts order.opaque_id
# => "izkpm55j334u8x"

# Use in URLs
order_url(order.opaque_id)
# => "/orders/V1StGXR8_Z5j"
```

### API Development

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Use longer IDs for API keys
  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Generate API key
api_key = ApiKey.create!(user_id: 1, name: "Mobile App")
puts api_key.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT1234567890"

# Use in API requests
# Authorization: Bearer V1StGXR8_Z5jdHi6B-myT1234567890
```

### Content Management

```ruby
class Article < ApplicationRecord
  include OpaqueId::Model

  # Use URL-safe characters for slugs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  self.opaque_id_length = 8
end

# Create an article
article = Article.create!(title: "My Article", content: "Content here")
puts article.opaque_id
# => "V1StGXR8"

# Use in URLs
article_url(article.opaque_id)
# => "/articles/V1StGXR8"
```

### User Management

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Require letter start for user IDs
  self.opaque_id_require_letter_start = true
end

# Create a user
user = User.create!(name: "John Doe", email: "john@example.com")
puts user.opaque_id
# => "izkpm55j334u8x9y2a" (starts with letter)

# Use in user profiles
user_url(user.opaque_id)
# => "/users/V1StGXR8_Z5jdHi6B-myT"
```

## Advanced Usage Patterns

### Batch Operations

```ruby
# Generate multiple IDs at once
ids = 100.times.map { OpaqueId.generate }
# => ["izkpm55j334u8x9y2a", "k8jh2mn9pl3qr7st1va", ...]

# Use in bulk operations
users_data = ids.map.with_index do |id, index|
  { opaque_id: id, name: "User #{index + 1}" }
end

User.insert_all(users_data)
```

### Conditional ID Generation

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  private

  def set_opaque_id
    # Only generate ID if not already set
    return if opaque_id.present?

    # Custom generation logic
    self.opaque_id = generate_custom_id
  end

  def generate_custom_id
    # Generate ID with custom logic
    base_id = OpaqueId.generate(size: 15)
    "usr_#{base_id}"
  end
end
```

### Error Handling

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Handle generation failures
  rescue_from OpaqueId::GenerationError do |exception|
    Rails.logger.error "Failed to generate opaque ID: #{exception.message}"
    # Fallback to a different generation method
    self.opaque_id = generate_fallback_id
  end

  private

  def generate_fallback_id
    # Fallback generation method
    "fallback_#{SecureRandom.hex(10)}"
  end
end
```

## Performance Considerations

### Batch Generation

```ruby
# Efficient batch generation
def generate_batch_ids(count, size: 21, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
  count.times.map { OpaqueId.generate(size: size, alphabet: alphabet) }
end

# Generate 1000 IDs
ids = generate_batch_ids(1000)
```

### Caching Generated IDs

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Cache the generated ID
  def opaque_id
    @opaque_id ||= super
  end
end
```

## Best Practices

### 1. Choose Appropriate Length

```ruby
# Short IDs for public URLs
self.opaque_id_length = 8

# Medium IDs for general use
self.opaque_id_length = 21

# Long IDs for sensitive data
self.opaque_id_length = 32
```

### 2. Select Suitable Alphabets

```ruby
# URL-safe for public URLs
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

# Fastest generation
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

# Custom for specific needs
self.opaque_id_alphabet = "0123456789ABCDEF"
```

### 3. Handle Collisions Gracefully

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Increase retry attempts for high-volume applications
  self.opaque_id_max_retry = 10
end
```

### 4. Use Appropriate Finder Methods

```ruby
# Use find_by_opaque_id for optional lookups
user = User.find_by_opaque_id(params[:id])

# Use find_by_opaque_id! for required lookups
user = User.find_by_opaque_id!(params[:id])
```

## Next Steps

Now that you understand the usage patterns:

1. **Explore [Configuration](configuration.md)** for advanced setup
2. **Check out [Use Cases](use-cases.md)** for more real-world scenarios
3. **Review [Performance](performance.md)** for optimization tips
4. **Read [API Reference](api-reference.md)** for complete documentation
5. **Learn about [Alphabets](alphabets.md)** for custom character sets
6. **Understand [Algorithms](algorithms.md)** for technical details
