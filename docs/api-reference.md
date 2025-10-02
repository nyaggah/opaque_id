---
layout: default
title: API Reference
nav_order: 12
description: "Complete API documentation for OpaqueId methods and classes"
permalink: /api-reference/
---

# API Reference

This document provides complete API documentation for OpaqueId, including all methods, classes, and configuration options.

- TOC
{:toc}

## Core Module: OpaqueId

The main module for generating opaque IDs.

### Constants

#### ALPHANUMERIC_ALPHABET

Default alphabet for ID generation.

```ruby
OpaqueId::ALPHANUMERIC_ALPHABET
# => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
```

**Characteristics:**

- **Length**: 62 characters
- **Characters**: A-Z, a-z, 0-9
- **Use case**: General purpose, URL-safe
- **Performance**: Good

#### STANDARD_ALPHABET

Standard alphabet for high-performance generation.

```ruby
OpaqueId::STANDARD_ALPHABET
# => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
```

**Characteristics:**

- **Length**: 64 characters
- **Characters**: A-Z, a-z, 0-9, -, \_
- **Use case**: High performance, URL-safe
- **Performance**: Best (optimized path)

### Methods

#### generate

Generates a cryptographically secure opaque ID.

```ruby
OpaqueId.generate(size: 21, alphabet: ALPHANUMERIC_ALPHABET)
```

**Parameters:**

| Parameter  | Type    | Default                 | Description                  |
| ---------- | ------- | ----------------------- | ---------------------------- |
| `size`     | Integer | `21`                    | Length of the generated ID   |
| `alphabet` | String  | `ALPHANUMERIC_ALPHABET` | Character set for generation |

**Returns:** `String` - The generated opaque ID

**Raises:**

- `ConfigurationError` - If size is not positive or alphabet is empty
- `GenerationError` - If ID generation fails

**Examples:**

```ruby
# Generate with default parameters
id = OpaqueId.generate
# => "V1StGXR8_Z5jdHi6B-myT"

# Generate with custom length
id = OpaqueId.generate(size: 10)
# => "V1StGXR8_Z5"

# Generate with custom alphabet
id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT"

# Generate with both custom parameters
id = OpaqueId.generate(size: 15, alphabet: "0123456789")
# => "123456789012345"
```

**Algorithm Selection:**

- **Fast Path**: Used for 64-character alphabets (bitwise optimization)
- **Unbiased Path**: Used for other alphabets (rejection sampling)
- **Direct Repetition**: Used for single-character alphabets

## ActiveRecord Concern: OpaqueId::Model

Provides ActiveRecord integration for automatic opaque ID generation.

### Class Methods

#### opaque_id_column

Gets or sets the column name for storing opaque IDs.

```ruby
self.opaque_id_column = :public_id
opaque_id_column
# => :public_id
```

**Default:** `:opaque_id`

**Returns:** `Symbol` - The column name

#### opaque_id_length

Gets or sets the length of generated opaque IDs.

```ruby
self.opaque_id_length = 15
opaque_id_length
# => 15
```

**Default:** `21`

**Returns:** `Integer` - The ID length

#### opaque_id_alphabet

Gets or sets the alphabet for ID generation.

```ruby
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
opaque_id_alphabet
# => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
```

**Default:** `OpaqueId::ALPHANUMERIC_ALPHABET`

**Returns:** `String` - The alphabet

#### opaque_id_require_letter_start

Gets or sets whether IDs must start with a letter.

```ruby
self.opaque_id_require_letter_start = true
opaque_id_require_letter_start
# => true
```

**Default:** `false`

**Returns:** `Boolean` - Whether letter start is required

#### opaque_id_max_retry

Gets or sets the maximum retry attempts for collision handling.

```ruby
self.opaque_id_max_retry = 5
opaque_id_max_retry
# => 5
```

**Default:** `3`

**Returns:** `Integer` - Maximum retry attempts

#### opaque_id_purge_chars

Gets or sets characters to exclude from generated IDs.

```ruby
self.opaque_id_purge_chars = ['0', 'O', 'l', 'I']
opaque_id_purge_chars
# => ['0', 'O', 'l', 'I']
```

**Default:** `[]`

**Returns:** `Array<String>` - Characters to exclude

#### find_by_opaque_id

Finds a record by its opaque ID.

```ruby
User.find_by_opaque_id("V1StGXR8_Z5jdHi6B-myT")
```

**Parameters:**

| Parameter   | Type   | Description                 |
| ----------- | ------ | --------------------------- |
| `opaque_id` | String | The opaque ID to search for |

**Returns:** `ActiveRecord::Base` or `nil` - The found record or nil

**Examples:**

```ruby
# Find existing user
user = User.find_by_opaque_id("V1StGXR8_Z5jdHi6B-myT")
# => #<User id: 1, opaque_id: "V1StGXR8_Z5jdHi6B-myT", ...>

# Find non-existent user
user = User.find_by_opaque_id("nonexistent")
# => nil
```

#### find_by_opaque_id!

Finds a record by its opaque ID, raising an exception if not found.

```ruby
User.find_by_opaque_id!("V1StGXR8_Z5jdHi6B-myT")
```

**Parameters:**

| Parameter   | Type   | Description                 |
| ----------- | ------ | --------------------------- |
| `opaque_id` | String | The opaque ID to search for |

**Returns:** `ActiveRecord::Base` - The found record

**Raises:**

- `ActiveRecord::RecordNotFound` - If no record is found

**Examples:**

```ruby
# Find existing user
user = User.find_by_opaque_id!("V1StGXR8_Z5jdHi6B-myT")
# => #<User id: 1, opaque_id: "V1StGXR8_Z5jdHi6B-myT", ...>

# Find non-existent user
user = User.find_by_opaque_id!("nonexistent")
# => ActiveRecord::RecordNotFound: Couldn't find User with opaque_id 'nonexistent'
```

### Instance Methods

#### opaque_id

Gets the opaque ID for the record.

```ruby
user.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"
```

**Returns:** `String` - The opaque ID

### Callbacks

#### before_create :set_opaque_id

Automatically generates an opaque ID before creating a record.

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end

user = User.new(name: "John Doe")
user.save!
puts user.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"
```

## Rails Generator: OpaqueId::Generators::InstallGenerator

Rails generator for setting up OpaqueId in your application.

### Usage

```bash
rails generate opaque_id:install ModelName [options]
```

### Arguments

| Argument     | Type   | Required | Description                 |
| ------------ | ------ | -------- | --------------------------- |
| `model_name` | String | Yes      | Name of the model to set up |

### Options

| Option          | Type   | Default     | Description                           |
| --------------- | ------ | ----------- | ------------------------------------- |
| `--column-name` | String | `opaque_id` | Column name for storing the opaque ID |

### Examples

```bash
# Basic usage
rails generate opaque_id:install User

# Custom column name
rails generate opaque_id:install User --column-name=public_id

# Multiple models
rails generate opaque_id:install User
rails generate opaque_id:install Post --column-name=slug
rails generate opaque_id:install Comment
```

### Generated Files

#### Migration

Creates a migration to add the opaque ID column:

```ruby
class AddOpaqueIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :opaque_id, :string
    add_index :users, :opaque_id, unique: true
  end
end
```

#### Model Update

Updates the model file to include the concern:

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end
```

With custom column name:

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_column = :public_id
end
```

## Error Classes

### OpaqueId::Error

Base error class for all OpaqueId errors.

```ruby
OpaqueId::Error
# => StandardError
```

### OpaqueId::ConfigurationError

Raised when configuration parameters are invalid.

```ruby
OpaqueId::ConfigurationError
# => OpaqueId::Error
```

**Examples:**

```ruby
# Invalid size
OpaqueId.generate(size: 0)
# => OpaqueId::ConfigurationError: Size must be positive

# Empty alphabet
OpaqueId.generate(alphabet: "")
# => OpaqueId::ConfigurationError: Alphabet cannot be empty
```

### OpaqueId::GenerationError

Raised when ID generation fails.

```ruby
OpaqueId::GenerationError
# => OpaqueId::Error
```

**Examples:**

```ruby
# Collision handling failure
class User < ApplicationRecord
  include OpaqueId::Model
  self.opaque_id_max_retry = 0
end

user = User.create!(name: "John Doe")
# => OpaqueId::GenerationError: Failed to generate opaque ID after 0 retries
```

## Configuration Examples

### Model Configuration

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Custom column name
  self.opaque_id_column = :public_id

  # Custom length
  self.opaque_id_length = 15

  # Custom alphabet
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

  # Require letter start
  self.opaque_id_require_letter_start = true

  # Max retry attempts
  self.opaque_id_max_retry = 5

  # Purge characters
  self.opaque_id_purge_chars = ['0', 'O', 'l', 'I']
end
```

### Global Configuration

```ruby
# config/initializers/opaque_id.rb
OpaqueId.configure do |config|
  config.default_length = 15
  config.default_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

## Usage Examples

### Basic Usage

```ruby
# Generate standalone ID
id = OpaqueId.generate
# => "V1StGXR8_Z5jdHi6B-myT"

# Generate with custom parameters
id = OpaqueId.generate(size: 10, alphabet: "0123456789")
# => "1234567890"
```

### ActiveRecord Integration

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end

# Create user with automatic ID generation
user = User.create!(name: "John Doe")
puts user.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"

# Find by opaque ID
found_user = User.find_by_opaque_id(user.opaque_id)
# => #<User id: 1, opaque_id: "V1StGXR8_Z5jdHi6B-myT", ...>
```

### Custom Configuration

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Numeric order numbers
  self.opaque_id_column = :order_number
  self.opaque_id_length = 8
  self.opaque_id_alphabet = "0123456789"
end

order = Order.create!(total: 99.99)
puts order.order_number
# => "12345678"
```

### Error Handling

```ruby
begin
  user = User.create!(name: "John Doe")
rescue OpaqueId::GenerationError => e
  Rails.logger.error "Failed to generate opaque ID: #{e.message}"
  # Handle error appropriately
end
```

## Performance Considerations

### Algorithm Selection

- **64-character alphabets**: Use fast path (bitwise operations)
- **Other alphabets**: Use unbiased path (rejection sampling)
- **Single-character alphabets**: Use direct repetition

### Memory Usage

- **Per ID**: ~50-70 bytes depending on length
- **Batch generation**: Linear scaling with count
- **Garbage collection**: Minimal impact

### Generation Speed

- **Fast Path**: Optimized for 64-character alphabets
- **Unbiased Path**: Slightly slower but ensures uniform distribution
- **Scaling**: Linear with ID length

## Security Considerations

### Entropy

- **21-character alphanumeric**: 125 bits entropy
- **21-character standard**: 126 bits entropy
- **15-character hexadecimal**: 60 bits entropy

### Collision Probability

- **1M IDs**: 2.3×10⁻¹⁵ probability
- **1B IDs**: 2.3×10⁻⁹ probability
- **1T IDs**: 2.3×10⁻³ probability

### Attack Resistance

- **Brute Force**: Extremely long time (exponential with ID length)
- **Timing Attacks**: Constant-time operations
- **Statistical Attacks**: Uniform distribution

## Best Practices

### 1. Choose Appropriate Configuration

```ruby
# High security
self.opaque_id_length = 21
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

# High performance
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

# Human readable
self.opaque_id_purge_chars = ['0', 'O', 'l', 'I']
```

### 2. Handle Errors Gracefully

```ruby
begin
  user = User.create!(name: "John Doe")
rescue OpaqueId::GenerationError => e
  # Log error and handle appropriately
  Rails.logger.error "ID generation failed: #{e.message}"
end
```

### 3. Use Appropriate Finder Methods

```ruby
# Optional lookup
user = User.find_by_opaque_id(params[:id])

# Required lookup
user = User.find_by_opaque_id!(params[:id])
```

### 4. Implement Proper Indexing

```ruby
# Ensure database indexes
add_index :users, :opaque_id, unique: true
```

## Next Steps

Now that you understand the API:

1. **Explore [Getting Started](getting-started.md)** for quick setup
2. **Check out [Usage](usage.md)** for practical examples
3. **Review [Configuration](configuration.md)** for advanced setup
4. **Read [Security](security.md)** for security considerations
