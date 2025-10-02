---
layout: default
title: Getting Started
nav_order: 2
description: "Quick setup and basic usage guide for OpaqueId"
permalink: /getting-started/
---

# Getting Started

This guide will help you get up and running with OpaqueId in your Rails application. We'll cover installation, basic setup, and common usage patterns.

## Prerequisites

Before you begin, ensure you have:

- **Ruby 3.2+** - OpaqueId requires modern Ruby features
- **Rails 8.0+** - Built for the latest Rails version
- **ActiveRecord 8.0+** - For model integration

## Installation

### Step 1: Add to Gemfile

Add OpaqueId to your application's Gemfile:

```ruby
gem 'opaque_id'
```

Then run:

```bash
bundle install
```

### Step 2: Generate Migration and Update Model

Use the Rails generator to set up OpaqueId for a specific model:

```bash
rails generate opaque_id:install User
```

This command will:

- Create a migration to add the `opaque_id` column
- Add a unique index on the `opaque_id` column
- Include the `OpaqueId::Model` concern in your model

### Step 3: Run Migration

Execute the migration:

```bash
rails db:migrate
```

### Step 4: Verify Setup

Check that your model has been updated correctly:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include OpaqueId::Model
end
```

## Basic Usage

### Creating Records

Once set up, OpaqueId automatically generates opaque IDs when you create new records:

```ruby
# Create a new user
user = User.create!(name: "John Doe", email: "john@example.com")

# The opaque_id is automatically generated
puts user.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"
```

### Finding Records

Use the provided finder methods to locate records by their opaque ID:

```ruby
# Find by opaque_id (returns nil if not found)
user = User.find_by_opaque_id("V1StGXR8_Z5jdHi6B-myT")

# Find by opaque_id (raises exception if not found)
user = User.find_by_opaque_id!("V1StGXR8_Z5jdHi6B-myT")
```

### Standalone ID Generation

You can also generate opaque IDs without ActiveRecord:

```ruby
# Generate a default opaque ID (21 characters, alphanumeric)
id = OpaqueId.generate
# => "V1StGXR8_Z5jdHi6B-myT"

# Generate with custom length
id = OpaqueId.generate(size: 10)
# => "V1StGXR8_Z5"

# Generate with custom alphabet
id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT"
```

## Common Patterns

### API Endpoints

Use opaque IDs in your API endpoints for better security:

```ruby
# routes.rb
resources :users, param: :opaque_id

# controller
class UsersController < ApplicationController
  def show
    @user = User.find_by_opaque_id!(params[:id])
  end
end
```

### URL Generation

Generate URLs using opaque IDs:

```ruby
# Instead of exposing internal IDs
user_path(user) # => /users/123

# Use opaque IDs
user_path(user.opaque_id) # => /users/V1StGXR8_Z5jdHi6B-myT
```

### Custom Column Names

If you prefer a different column name, specify it during generation:

```bash
rails generate opaque_id:install User --column-name=public_id
```

This will:

- Create a `public_id` column instead of `opaque_id`
- Add the configuration to your model automatically

## Configuration Options

OpaqueId is highly configurable. Here are the most common options:

### Model-Level Configuration

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Custom column name
  self.opaque_id_column = :public_id

  # Custom length (default: 21)
  self.opaque_id_length = 15

  # Custom alphabet (default: ALPHANUMERIC_ALPHABET)
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

  # Require letter start (default: false)
  self.opaque_id_require_letter_start = true

  # Max retry attempts for collision handling (default: 3)
  self.opaque_id_max_retry = 5
end
```

### Global Configuration

You can also configure OpaqueId globally in an initializer:

```ruby
# config/initializers/opaque_id.rb
OpaqueId.configure do |config|
  config.default_length = 15
  config.default_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

## Built-in Alphabets

OpaqueId comes with two pre-configured alphabets:

### ALPHANUMERIC_ALPHABET (Default)

- **Characters**: `A-Z`, `a-z`, `0-9` (62 characters)
- **Use case**: General purpose, URL-safe
- **Example**: `V1StGXR8_Z5jdHi6B-myT`

### STANDARD_ALPHABET

- **Characters**: `A-Z`, `a-z`, `0-9`, `-`, `_` (64 characters)
- **Use case**: When you need the fastest generation
- **Example**: `V1StGXR8_Z5jdHi6B-myT`

## Error Handling

OpaqueId provides comprehensive error handling:

```ruby
begin
  user = User.create!(name: "John Doe")
rescue OpaqueId::GenerationError => e
  # Handle ID generation failure (very rare)
  Rails.logger.error "Failed to generate opaque ID: #{e.message}"
end
```

## Next Steps

Now that you have OpaqueId set up, you might want to explore:

- [Installation](installation.md) - Detailed installation guide
- [Usage](usage.md) - Comprehensive usage examples
- [Configuration](configuration.md) - Detailed configuration guide
- [Alphabets](alphabets.md) - Built-in alphabets and custom options
- [API Reference](api-reference.md) - Complete API documentation
- [Use Cases](use-cases.md) - Real-world examples and applications
- [Performance](performance.md) - Benchmarks and optimization tips
- [Security](security.md) - Security considerations and best practices

## Troubleshooting

### Common Issues

**Migration fails**: Ensure you're using Rails 8.0+ and have the correct database permissions.

**Generator not found**: Make sure you've added `gem 'opaque_id'` to your Gemfile and run `bundle install`.

**ID generation fails**: This is extremely rare, but if it happens, check your database constraints and ensure the column allows the configured length.

### Getting Help

If you encounter issues:

1. Check the [API Reference](api-reference.md) for detailed method documentation
2. Review the [Usage](usage.md) guide for common patterns
3. Check the [Use Cases](use-cases.md) for real-world examples
4. Open an issue on [GitHub](https://github.com/nyaggah/opaque_id/issues) with details about your setup and the error
