---
layout: default
title: Alphabets
nav_order: 6
description: "Complete guide to built-in alphabets and custom alphabet creation"
permalink: /alphabets/
---

# Alphabets

OpaqueId provides flexible alphabet configuration for generating IDs with different character sets. This guide covers built-in alphabets, custom alphabet creation, and best practices for alphabet selection.

- TOC
{:toc}

## Built-in Alphabets

OpaqueId comes with two pre-configured alphabets optimized for different use cases.

### ALPHANUMERIC_ALPHABET (Default)

The default alphabet provides a good balance of security, readability, and URL safety.

```ruby
# Characters: A-Z, a-z, 0-9 (62 characters)
# Use case: General purpose, URL-safe
# Example output: "V1StGXR8_Z5jdHi6B-myT"

class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end
```

**Characteristics:**

- **Length**: 62 characters
- **Characters**: `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`
- **URL-safe**: Yes (no special characters)
- **Human-readable**: Yes (no confusing characters)
- **Performance**: Good (62 characters)

**Use cases:**

- General purpose ID generation
- Public URLs and user-facing identifiers
- APIs and web services
- Database primary keys

### STANDARD_ALPHABET

The standard alphabet provides the fastest generation speed with 64 characters.

```ruby
# Characters: A-Z, a-z, 0-9, -, _ (64 characters)
# Use case: Fastest generation, URL-safe
# Example output: "V1StGXR8_Z5jdHi6B-myT"

class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

**Characteristics:**

- **Length**: 64 characters
- **Characters**: `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_`
- **URL-safe**: Yes (includes hyphens and underscores)
- **Human-readable**: Yes (minimal special characters)
- **Performance**: Best (64 characters, optimized path)

**Use cases:**

- High-performance applications
- Internal system identifiers
- APIs with high throughput
- Background job systems

## Alphabet Comparison

| Alphabet                | Characters           | Length | URL-Safe | Performance | Use Case         |
| ----------------------- | -------------------- | ------ | -------- | ----------- | ---------------- |
| `ALPHANUMERIC_ALPHABET` | A-Z, a-z, 0-9        | 62     | ✅       | Good        | General purpose  |
| `STANDARD_ALPHABET`     | A-Z, a-z, 0-9, -, \_ | 64     | ✅       | Best        | High performance |

## Custom Alphabets

Create custom alphabets for specific requirements and use cases.

### Numeric Only

Generate numeric-only IDs for order numbers, invoice numbers, etc.

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Generate numeric-only IDs
  self.opaque_id_alphabet = "0123456789"
  self.opaque_id_length = 10
end

# Example output: "1234567890"
```

**Use cases:**

- Order numbers
- Invoice numbers
- Reference numbers
- Sequential-looking IDs

### Hexadecimal

Generate hexadecimal IDs for API keys, tokens, etc.

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Generate hexadecimal IDs
  self.opaque_id_alphabet = "0123456789abcdef"
  self.opaque_id_length = 16
end

# Example output: "a1b2c3d4e5f67890"
```

**Use cases:**

- API keys
- Authentication tokens
- Session identifiers
- Cryptographic keys

### URL-Safe Characters

Generate IDs with maximum URL safety.

```ruby
class Article < ApplicationRecord
  include OpaqueId::Model

  # Generate URL-safe IDs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  self.opaque_id_length = 8
end

# Example output: "V1StGXR8"
```

**Use cases:**

- URL slugs
- Public identifiers
- Social media sharing
- Email-friendly IDs

### Base64-Style

Generate Base64-style IDs for maximum character diversity.

```ruby
class Document < ApplicationRecord
  include OpaqueId::Model

  # Generate Base64-style IDs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
  self.opaque_id_length = 12
end

# Example output: "V1StGXR8_Z5j"
```

**Use cases:**

- Document identifiers
- File references
- Binary data representation
- High-entropy requirements

### Uppercase Only

Generate uppercase-only IDs for better readability.

```ruby
class Product < ApplicationRecord
  include OpaqueId::Model

  # Generate uppercase-only IDs
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  self.opaque_id_length = 10
end

# Example output: "V1STGXR8Z5"
```

**Use cases:**

- Product codes
- SKUs
- License keys
- Human-readable identifiers

### Lowercase Only

Generate lowercase-only IDs for consistent formatting.

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Generate lowercase-only IDs
  self.opaque_id_alphabet = "abcdefghijklmnopqrstuvwxyz0123456789"
  self.opaque_id_length = 12
end

# Example output: "v1stgxr8z5jd"
```

**Use cases:**

- Usernames
- Subdomains
- File names
- Consistent formatting

### No Confusing Characters

Generate IDs without characters that can be easily confused.

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Exclude confusing characters: 0, O, l, I, 1
  self.opaque_id_alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
  self.opaque_id_length = 15
end

# Example output: "V2StGXR8Z5jdHi6B"
```

**Use cases:**

- Human-readable IDs
- Voice communication
- Hand-written transcription
- Accessibility

### Specialized Characters

Generate IDs with specific character sets for unique requirements.

```ruby
class Game < ApplicationRecord
  include OpaqueId::Model

  # Game-friendly characters (no vowels to avoid words)
  self.opaque_id_alphabet = "BCDFGHJKLMNPQRSTVWXYZbcdfghjklmnpqrstvwxyz23456789"
  self.opaque_id_length = 8
end

# Example output: "B2StGXR8"
```

**Use cases:**

- Game codes
- Room identifiers
- Tournament codes
- Content filtering

## Alphabet Selection Guide

### Choose by Use Case

#### Public URLs

```ruby
# URL-safe, human-readable
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
```

#### High Performance

```ruby
# Fastest generation
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
```

#### Human Readable

```ruby
# No confusing characters
self.opaque_id_alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"
```

#### Maximum Security

```ruby
# High entropy, many characters
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
```

#### Numeric Only

```ruby
# Numbers only
self.opaque_id_alphabet = "0123456789"
```

### Choose by Length

#### Short IDs (8-12 characters)

```ruby
# Use larger alphabets for shorter IDs
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
self.opaque_id_length = 8
```

#### Medium IDs (15-21 characters)

```ruby
# Standard alphabets work well
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
self.opaque_id_length = 21
```

#### Long IDs (32+ characters)

```ruby
# Any alphabet works, consider performance
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
self.opaque_id_length = 32
```

## Performance Considerations

### Alphabet Size Impact

Larger alphabets generally provide better performance due to optimized algorithms:

```ruby
# 64 characters - fastest (optimized path)
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

# 62 characters - good performance
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

# 16 characters - slower (rejection sampling)
self.opaque_id_alphabet = "0123456789abcdef"

# 10 characters - slowest (rejection sampling)
self.opaque_id_alphabet = "0123456789"
```

### Character Set Optimization

```ruby
# Optimized for 64 characters
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

# Good performance with 62 characters
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

# Slower with smaller sets
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
```

## Security Considerations

### Entropy and Security

Larger alphabets provide more entropy per character:

```ruby
# High entropy (64 characters)
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
self.opaque_id_length = 21
# Entropy: 21 * log2(64) = 126 bits

# Medium entropy (62 characters)
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
self.opaque_id_length = 21
# Entropy: 21 * log2(62) = 125 bits

# Lower entropy (16 characters)
self.opaque_id_alphabet = "0123456789abcdef"
self.opaque_id_length = 21
# Entropy: 21 * log2(16) = 84 bits
```

### Character Predictability

Avoid predictable character patterns:

```ruby
# Good - random character distribution
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

# Avoid - sequential patterns
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Avoid - common patterns
self.opaque_id_alphabet = "0123456789"
```

## Best Practices

### 1. Choose Appropriate Alphabet Size

- **64 characters**: Best performance, good security
- **62 characters**: Good balance, URL-safe
- **32 characters**: Moderate performance, specific use cases
- **16 characters**: Slower, specific requirements
- **10 characters**: Slowest, numeric-only needs

### 2. Consider URL Safety

```ruby
# URL-safe characters
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

# Avoid URL-unsafe characters
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
```

### 3. Avoid Confusing Characters

```ruby
# Exclude confusing characters
self.opaque_id_alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789"

# Or use purge_chars option
self.opaque_id_purge_chars = ['0', 'O', 'l', 'I', '1']
```

### 4. Test Your Alphabet

```ruby
# Test alphabet generation
class User < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  self.opaque_id_length = 10
end

# Generate test IDs
5.times { puts User.new.opaque_id }
# => "V1STGXR8Z5"
# => "K8JH2MN9PL"
# => "Q3RT7S1V4X"
# => "B6NF9C2M8Y"
# => "D4HG7K1P5W"
```

## Common Alphabet Patterns

### E-commerce

```ruby
# Order numbers - numeric
class Order < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = "0123456789"
  self.opaque_id_length = 8
end

# Product codes - alphanumeric
class Product < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  self.opaque_id_length = 12
end
```

### API Development

```ruby
# API keys - hexadecimal
class ApiKey < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = "0123456789abcdef"
  self.opaque_id_length = 32
end

# API tokens - standard
class ApiToken < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
  self.opaque_id_length = 24
end
```

### Content Management

```ruby
# Article slugs - URL-safe
class Article < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
  self.opaque_id_length = 8
end

# Comments - standard
class Comment < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  self.opaque_id_length = 15
end
```

## Next Steps

Now that you understand alphabet configuration:

1. **Explore [Configuration](configuration.md)** for complete configuration options
2. **Check out [Use Cases](use-cases.md)** for real-world alphabet usage
3. **Review [Performance](performance.md)** for alphabet optimization tips
4. **Read [API Reference](api-reference.md)** for complete alphabet documentation
