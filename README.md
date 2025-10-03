# OpaqueId

[![Gem Version](https://badge.fury.io/rb/opaque_id.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/opaque_id)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Gem Downloads](https://img.shields.io/gem/dt/opaque_id)](https://rubygems.org/gems/opaque_id)

A simple Ruby gem for generating secure, opaque IDs for ActiveRecord models. OpaqueId provides a drop-in replacement for `nanoid.rb` using Ruby's built-in `SecureRandom` methods with optimized algorithms for uniform distribution.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
  - [Requirements](#requirements)
  - [Using Bundler (Recommended)](#using-bundler-recommended)
  - [Manual Installation](#manual-installation)
  - [From Source](#from-source)
  - [Troubleshooting](#troubleshooting)
- [Quick Start](#quick-start)
  - [1. Generate Migration and Update Model](#1-generate-migration-and-update-model)
  - [2. Run Migration](#2-run-migration)
  - [3. Use in Your Models](#3-use-in-your-models)
- [Usage](#usage)
  - [Standalone ID Generation](#standalone-id-generation)
  - [Real-World Examples](#real-world-examples)
  - [ActiveRecord Integration](#activerecord-integration)
  - [Rails Generator](#rails-generator)
- [Configuration Options](#configuration-options)
  - [Configuration Details](#configuration-details)
- [Built-in Alphabets](#built-in-alphabets)
  - [`ALPHANUMERIC_ALPHABET` (Default)](#alphanumeric_alphabet-default)
  - [`STANDARD_ALPHABET`](#standard_alphabet)
  - [Alphabet Comparison](#alphabet-comparison)
  - [Custom Alphabets](#custom-alphabets)
  - [Alphabet Selection Guide](#alphabet-selection-guide)
- [Algorithm Details](#algorithm-details)
  - [Fast Path Algorithm (64-character alphabets)](#fast-path-algorithm-64-character-alphabets)
  - [Unbiased Path Algorithm (other alphabets)](#unbiased-path-algorithm-other-alphabets)
  - [Algorithm Selection](#algorithm-selection)
- [Performance Benchmarks](#performance-benchmarks)
  - [Generation Speed (IDs per second)](#generation-speed-ids-per-second)
  - [Memory Usage](#memory-usage)
  - [Collision Probability](#collision-probability)
  - [Performance Characteristics](#performance-characteristics)
  - [Real-World Performance](#real-world-performance)
  - [Performance Optimization Tips](#performance-optimization-tips)
- [Error Handling](#error-handling)
- [Security Considerations](#security-considerations)
  - [Cryptographic Security](#cryptographic-security)
  - [Security Best Practices](#security-best-practices)
  - [Security Recommendations](#security-recommendations)
  - [Threat Model Considerations](#threat-model-considerations)
  - [Security Audit Checklist](#security-audit-checklist)
- [Use Cases](#use-cases)
  - [E-Commerce Applications](#e-commerce-applications)
  - [API Development](#api-development)
  - [Content Management Systems](#content-management-systems)
  - [User Management](#user-management)
  - [Background Job Systems](#background-job-systems)
  - [Short URL Services](#short-url-services)
  - [Real-Time Applications](#real-time-applications)
  - [Analytics and Tracking](#analytics-and-tracking)
  - [Use Case Summary](#use-case-summary)
- [Development](#development)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
  - [Development Commands](#development-commands)
  - [Project Structure](#project-structure)
  - [Testing Strategy](#testing-strategy)
  - [Release Process](#release-process)
  - [Development Guidelines](#development-guidelines)
- [Contributing](#contributing)
  - [Reporting Issues](#reporting-issues)
  - [Issue Guidelines](#issue-guidelines)
  - [Code of Conduct](#code-of-conduct)
  - [Community Guidelines](#community-guidelines)
  - [Getting Help](#getting-help)
- [License](#license)
  - [License Summary](#license-summary)
  - [Full License Text](#full-license-text)
  - [License Compatibility](#license-compatibility)
  - [Copyright](#copyright)
  - [Third-Party Licenses](#third-party-licenses)
  - [Legal Disclaimer](#legal-disclaimer)
- [Code of Conduct](#code-of-conduct-1)
- [Acknowledgements](#acknowledgements)

## Features

- **🔐 Cryptographically Secure**: Uses Ruby's `SecureRandom` for secure ID generation
- **⚡ Performance Optimized**: Efficient algorithms with fast paths for 64-character alphabets
- **🎯 Collision Resistant**: Built-in collision detection with configurable retry attempts
- **🔧 Highly Configurable**: Customizable alphabet, length, column name, and validation rules
- **🚀 Rails Integration**: ActiveRecord integration with automatic ID generation
- **📦 Rails Generator**: One-command setup with `rails generate opaque_id:install`
- **🧪 Tested**: Includes test suite with statistical uniformity tests
- **📚 Rails 8.0+ Compatible**: Built for modern Rails applications

## Installation

### Requirements

- Ruby 3.2.0 or higher
- Rails 8.0 or higher
- ActiveRecord 8.0 or higher

### Using Bundler (Recommended)

Add this line to your application's Gemfile:

```ruby
gem 'opaque_id'
```

And then execute:

```bash
bundle install
```

### Manual Installation

If you're not using Bundler, you can install the gem directly:

```bash
gem install opaque_id
```

### From Source

To install from the latest source:

```ruby
# In your Gemfile
gem 'opaque_id', git: 'https://github.com/nyaggah/opaque_id.git'
```

```bash
bundle install
```

### Troubleshooting

**Rails Version Compatibility**: If you're using an older version of Rails, you may need to check compatibility. OpaqueId is designed for Rails 8.0+.

**Ruby Version**: Ensure you're using Ruby 3.2.0 or higher. Check your version with:

```bash
ruby --version
```

## Quick Start

### 1. Generate Migration and Update Model

```bash
rails generate opaque_id:install users
```

This will:

- Create a migration to add an `opaque_id` column with a unique index
- Automatically add `include OpaqueId::Model` to your `User` model

### 2. Run Migration

```bash
rails db:migrate
```

### 3. Use in Your Models

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end

# IDs are automatically generated on creation
user = User.create!(name: "John Doe")
puts user.opaque_id  # => "V1StGXR8_Z5jdHi6B-myT"

# Find by opaque ID
user = User.find_by_opaque_id("V1StGXR8_Z5jdHi6B-myT")
user = User.find_by_opaque_id!("V1StGXR8_Z5jdHi6B-myT")  # raises if not found
```

## Usage

### Standalone ID Generation

OpaqueId can be used independently of ActiveRecord for generating secure IDs in any Ruby application:

#### Basic Usage

```ruby
# Generate with default settings (21 characters, alphanumeric)
id = OpaqueId.generate
# => "V1StGXR8_Z5jdHi6B-myT"

# Custom length
id = OpaqueId.generate(size: 10)
# => "V1StGXR8_Z5"

# Custom alphabet
id = OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT"

# Custom alphabet and length
id = OpaqueId.generate(size: 8, alphabet: "ABCDEFGH")
# => "ABCDEFGH"

# Generate multiple IDs
ids = 5.times.map { OpaqueId.generate(size: 8) }
# => ["V1StGXR8", "Z5jdHi6B", "myT12345", "ABCdefGH", "IJKlmnoP"]
```

#### Standalone Use Cases

##### Background Job IDs

```ruby
# Generate unique job identifiers
class BackgroundJob
  def self.enqueue(job_class, *args)
    job_id = OpaqueId.generate(size: 12)
    # Store job with unique ID
    puts "Enqueued job #{job_class} with ID: #{job_id}"
    job_id
  end
end

job_id = BackgroundJob.enqueue(ProcessDataJob, user_id: 123)
# => "V1StGXR8_Z5jd"
```

##### Temporary File Names

```ruby
# Generate unique temporary filenames
def create_temp_file(content)
  temp_filename = "temp_#{OpaqueId.generate(size: 8)}.txt"
  File.write(temp_filename, content)
  temp_filename
end

filename = create_temp_file("Hello World")
# => "temp_V1StGXR8.txt"
```

##### Cache Keys

```ruby
# Generate cache keys for different data types
class CacheManager
  def self.user_cache_key(user_id)
    "user:#{OpaqueId.generate(size: 6)}:#{user_id}"
  end

  def self.session_cache_key
    "session:#{OpaqueId.generate(size: 16)}"
  end
end

user_key = CacheManager.user_cache_key(123)
# => "user:V1StGX:123"

session_key = CacheManager.session_cache_key
# => "session:V1StGXR8_Z5jdHi6B"
```

##### Webhook Signatures

```ruby
# Generate webhook signatures
class WebhookService
  def self.generate_signature(payload)
    timestamp = Time.current.to_i
    nonce = OpaqueId.generate(size: 16)
    signature = "#{timestamp}:#{nonce}:#{payload.hash}"
    signature
  end
end

signature = WebhookService.generate_signature({ user_id: 123 })
# => "1703123456:V1StGXR8_Z5jdHi6B:1234567890"
```

##### Database Migration IDs

```ruby
# Generate unique migration identifiers
def create_migration(name)
  timestamp = Time.current.strftime("%Y%m%d%H%M%S")
  unique_id = OpaqueId.generate(size: 4)
  "#{timestamp}_#{unique_id}_#{name}"
end

migration_name = create_migration("add_user_preferences")
# => "20231221143022_V1St_add_user_preferences"
```

##### Email Tracking IDs

```ruby
# Generate email tracking pixel IDs
class EmailService
  def self.tracking_pixel_id
    OpaqueId.generate(size: 20, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
  end
end

tracking_id = EmailService.tracking_pixel_id
# => "V1StGXR8Z5jdHi6BmyT12"

# Use in email template
# <img src="https://example.com/track/#{tracking_id}" width="1" height="1" />
```

##### API Request IDs

```ruby
# Generate request IDs for API logging
class ApiLogger
  def self.log_request(endpoint, params)
    request_id = OpaqueId.generate(size: 12)
    Rails.logger.info "Request #{request_id}: #{endpoint} - #{params}"
    request_id
  end
end

request_id = ApiLogger.log_request("/api/users", { page: 1 })
# => "V1StGXR8_Z5jd"
```

##### Batch Processing IDs

```ruby
# Generate batch processing identifiers
class BatchProcessor
  def self.process_batch(items)
    batch_id = OpaqueId.generate(size: 10)
    puts "Processing batch #{batch_id} with #{items.count} items"

    items.each_with_index do |item, index|
      item_id = "#{batch_id}_#{index.to_s.rjust(3, '0')}"
      puts "Processing item #{item_id}: #{item}"
    end

    batch_id
  end
end

batch_id = BatchProcessor.process_batch([1, 2, 3, 4, 5])
# => "V1StGXR8_Z5"
# => Processing item V1StGXR8_Z5_000: 1
# => Processing item V1StGXR8_Z5_001: 2
# => ...
```

### Real-World Examples

#### API Keys

```ruby
# Generate secure API keys
api_key = OpaqueId.generate(size: 32, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
# => "V1StGXR8_Z5jdHi6B-myT1234567890AB"

# Store in your API key model
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :key
  self.opaque_id_length = 32
end
```

#### Short URLs

```ruby
# Generate short URL identifiers
short_id = OpaqueId.generate(size: 6, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
# => "V1StGX"

# Use in your URL shortener
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :short_code
  self.opaque_id_length = 6
end
```

#### File Uploads

```ruby
# Generate unique filenames
filename = OpaqueId.generate(size: 12, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
# => "V1StGXR8_Z5jd"

# Use in your file upload system
class Upload < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_column = :filename
  self.opaque_id_length = 12
end
```

### ActiveRecord Integration

#### Basic Usage

```ruby
class Post < ApplicationRecord
  include OpaqueId::Model
end

# Create a new post - opaque_id is automatically generated
post = Post.create!(title: "Hello World", content: "This is my first post")
puts post.opaque_id  # => "V1StGXR8_Z5jdHi6B-myT"

# Create multiple posts
posts = Post.create!([
  { title: "Post 1", content: "Content 1" },
  { title: "Post 2", content: "Content 2" },
  { title: "Post 3", content: "Content 3" }
])

posts.each { |p| puts "#{p.title}: #{p.opaque_id}" }
# => Post 1: V1StGXR8_Z5jdHi6B-myT
# => Post 2: Z5jdHi6B-myT12345
# => Post 3: myT12345-ABCdefGH
```

#### Custom Configuration

OpaqueId provides extensive configuration options to tailor ID generation to your specific needs:

##### Basic Customization

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Use a different column name
  self.opaque_id_column = :public_id

  # Custom length and alphabet
  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

  # Require ID to start with a letter
  self.opaque_id_require_letter_start = true

  # Remove specific characters
  self.opaque_id_purge_chars = ['0', 'O', 'I', 'l']

  # Maximum retry attempts for collision resolution
  self.opaque_id_max_retry = 5
end
```

##### API Key Configuration

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Use 'key' as the column name
  self.opaque_id_column = :key

  # Longer IDs for better security
  self.opaque_id_length = 32

  # Alphanumeric only for API keys
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

  # Remove confusing characters
  self.opaque_id_purge_chars = ['0', 'O', 'I', 'l', '1']

  # More retry attempts for high-volume systems
  self.opaque_id_max_retry = 10
end

# Generated API keys will look like: "V1StGXR8Z5jdHi6BmyT1234567890AB"
```

##### Short URL Configuration

```ruby
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  # Use 'code' as the column name
  self.opaque_id_column = :code

  # Shorter IDs for URLs
  self.opaque_id_length = 6

  # URL-safe characters only
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

  # Remove confusing characters for better UX
  self.opaque_id_purge_chars = ['0', 'O', 'I', 'l', '1']

  # Require letter start for better readability
  self.opaque_id_require_letter_start = true
end

# Generated short codes will look like: "V1StGX"
```

##### File Upload Configuration

```ruby
class Upload < ApplicationRecord
  include OpaqueId::Model

  # Use 'filename' as the column name
  self.opaque_id_column = :filename

  # Medium length for filenames
  self.opaque_id_length = 12

  # Alphanumeric with hyphens for filenames
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET + "-"

  # Remove problematic characters for filesystems
  self.opaque_id_purge_chars = ['/', '\\', ':', '*', '?', '"', '<', '>', '|']
end

# Generated filenames will look like: "V1StGXR8-Z5jd"
```

##### Session Token Configuration

```ruby
class Session < ApplicationRecord
  include OpaqueId::Model

  # Use 'token' as the column name
  self.opaque_id_column = :token

  # Longer tokens for security
  self.opaque_id_length = 24

  # URL-safe characters for cookies
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

  # Remove confusing characters
  self.opaque_id_purge_chars = ['0', 'O', 'I', 'l', '1']

  # More retry attempts for high-concurrency
  self.opaque_id_max_retry = 8
end

# Generated session tokens will look like: "V1StGXR8_Z5jdHi6B-myT123"
```

##### Custom Alphabet Examples

```ruby
# Numeric only
class Order < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_alphabet = "0123456789"
  self.opaque_id_length = 8
end
# Generated: "12345678"

# Uppercase only
class Product < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  self.opaque_id_length = 6
end
# Generated: "ABCDEF"

# Custom character set
class Invite < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # No confusing chars
  self.opaque_id_length = 8
end
# Generated: "ABCDEFGH"
```

#### Finder Methods

```ruby
# Find by opaque ID (returns nil if not found)
user = User.find_by_opaque_id("V1StGXR8_Z5jdHi6B-myT")
if user
  puts "Found user: #{user.name}"
else
  puts "User not found"
end

# Find by opaque ID (raises ActiveRecord::RecordNotFound if not found)
user = User.find_by_opaque_id!("V1StGXR8_Z5jdHi6B-myT")
puts "Found user: #{user.name}"

# Use in controllers for public-facing URLs
class PostsController < ApplicationController
  def show
    @post = Post.find_by_opaque_id!(params[:id])
    # This allows URLs like /posts/V1StGXR8_Z5jdHi6B-myT
  end
end

# Use in API endpoints
class Api::UsersController < ApplicationController
  def show
    user = User.find_by_opaque_id(params[:id])
    if user
      render json: { id: user.opaque_id, name: user.name }
    else
      render json: { error: "User not found" }, status: 404
    end
  end
end
```

### Rails Generator

#### Basic Usage

```bash
rails generate opaque_id:install users
```

#### Custom Column Name

```bash
rails generate opaque_id:install users --column-name=public_id
```

#### What the Generator Does

1. **Creates Migration**: Adds `opaque_id` column with unique index
2. **Updates Model**: Automatically adds `include OpaqueId::Model` to your model
3. **Handles Edge Cases**: Detects if concern is already included, handles missing model files

## Configuration Options

OpaqueId provides comprehensive configuration options to customize ID generation behavior:

| Option                           | Type            | Default                 | Description                                     | Example Usage                                           |
| -------------------------------- | --------------- | ----------------------- | ----------------------------------------------- | ------------------------------------------------------- |
| `opaque_id_column`               | `Symbol`        | `:opaque_id`            | Column name for storing the opaque ID           | `self.opaque_id_column = :public_id`                    |
| `opaque_id_length`               | `Integer`       | `21`                    | Length of generated IDs                         | `self.opaque_id_length = 32`                            |
| `opaque_id_alphabet`             | `String`        | `ALPHANUMERIC_ALPHABET` | Character set for ID generation                 | `self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET` |
| `opaque_id_require_letter_start` | `Boolean`       | `false`                 | Require ID to start with a letter               | `self.opaque_id_require_letter_start = true`            |
| `opaque_id_purge_chars`          | `Array<String>` | `[]`                    | Characters to remove from generated IDs         | `self.opaque_id_purge_chars = ['0', 'O', 'I', 'l']`     |
| `opaque_id_max_retry`            | `Integer`       | `3`                     | Maximum retry attempts for collision resolution | `self.opaque_id_max_retry = 10`                         |

### Configuration Details

#### `opaque_id_column`

- **Purpose**: Specifies the database column name for storing opaque IDs
- **Use Cases**: When you want to use a different column name (e.g., `public_id`, `external_id`, `key`)
- **Example**: `self.opaque_id_column = :public_id` → IDs stored in `public_id` column

#### `opaque_id_length`

- **Purpose**: Controls the length of generated IDs
- **Range**: 1 to 255 characters (practical limit)
- **Performance**: Longer IDs are more secure but use more storage
- **Examples**:
  - `6` → Short URLs: `"V1StGX"`
  - `21` → Default: `"V1StGXR8_Z5jdHi6B-myT"`
  - `32` → API Keys: `"V1StGXR8_Z5jdHi6B-myT1234567890AB"`

#### `opaque_id_alphabet`

- **Purpose**: Defines the character set used for ID generation
- **Built-in Options**: `ALPHANUMERIC_ALPHABET`, `STANDARD_ALPHABET`
- **Custom**: Any string of unique characters
- **Security**: Larger alphabets provide more entropy per character
- **Examples**:
  - `"0123456789"` → Numeric only: `"12345678"`
  - `"ABCDEFGHIJKLMNOPQRSTUVWXYZ"` → Uppercase only: `"ABCDEF"`
  - `"ABCDEFGHJKLMNPQRSTUVWXYZ23456789"` → No confusing chars: `"ABCDEFGH"`

#### `opaque_id_require_letter_start`

- **Purpose**: Ensures IDs start with a letter for better readability
- **Use Cases**: When IDs are user-facing or need to be easily readable
- **Performance**: Slight overhead due to rejection sampling
- **Example**: `true` → `"V1StGXR8_Z5jdHi6B-myT"`, `false` → `"1StGXR8_Z5jdHi6B-myT"`

#### `opaque_id_purge_chars`

- **Purpose**: Removes problematic characters from generated IDs
- **Use Cases**: Avoiding confusing characters (0/O, 1/I/l) or filesystem-unsafe chars
- **Performance**: Minimal overhead, applied after generation
- **Examples**:
  - `['0', 'O', 'I', 'l']` → Removes visually similar characters
  - `['/', '\\', ':', '*', '?', '"', '<', '>', '|']` → Removes filesystem-unsafe characters

#### `opaque_id_max_retry`

- **Purpose**: Controls collision resolution attempts
- **Use Cases**: High-volume systems where collisions are more likely
- **Performance**: Higher values provide better collision resolution but may slow down creation
- **Examples**:
  - `3` → Default, good for most applications
  - `10` → High-volume systems with many concurrent creations
  - `1` → When you want to fail fast on collisions

## Built-in Alphabets

OpaqueId provides two pre-configured alphabets optimized for different use cases:

### `ALPHANUMERIC_ALPHABET` (Default)

```ruby
OpaqueId::ALPHANUMERIC_ALPHABET
# => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
```

**Characteristics:**

- **Length**: 62 characters
- **Characters**: A-Z, a-z, 0-9
- **URL Safety**: ✅ Fully URL-safe
- **Readability**: ✅ High (no confusing characters)
- **Entropy**: 62^n possible combinations
- **Performance**: ⚡ Fast path (64-character optimization)

**Best For:**

- API keys and tokens
- Public-facing URLs
- User-visible identifiers
- Database primary keys
- General-purpose ID generation

**Example Output:**

```ruby
OpaqueId.generate(size: 8, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
# => "V1StGXR8"
```

### `STANDARD_ALPHABET`

```ruby
OpaqueId::STANDARD_ALPHABET
# => "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
```

**Characteristics:**

- **Length**: 64 characters
- **Characters**: A-Z, a-z, 0-9, -, \_
- **URL Safety**: ✅ Fully URL-safe
- **Readability**: ✅ High (no confusing characters)
- **Entropy**: 64^n possible combinations
- **Performance**: ⚡ Fast path (64-character optimization)

**Best For:**

- Short URLs and links
- File names and paths
- Configuration keys
- Session identifiers
- High-performance applications

**Example Output:**

```ruby
OpaqueId.generate(size: 8, alphabet: OpaqueId::STANDARD_ALPHABET)
# => "V1StGXR8"
```

### Alphabet Comparison

| Feature                   | ALPHANUMERIC_ALPHABET | STANDARD_ALPHABET |
| ------------------------- | --------------------- | ----------------- |
| **Character Count**       | 62                    | 64                |
| **URL Safe**              | ✅ Yes                | ✅ Yes            |
| **Performance**           | ⚡ Fast               | ⚡ Fastest        |
| **Entropy per Character** | ~5.95 bits            | 6 bits            |
| **Collision Resistance**  | High                  | Highest           |
| **Use Case**              | General purpose       | High performance  |

### Custom Alphabets

You can also create custom alphabets for specific needs:

```ruby
# Numeric only (10 characters)
numeric_alphabet = "0123456789"
OpaqueId.generate(size: 8, alphabet: numeric_alphabet)
# => "12345678"

# Uppercase only (26 characters)
uppercase_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
OpaqueId.generate(size: 6, alphabet: uppercase_alphabet)
# => "ABCDEF"

# No confusing characters (58 characters)
safe_alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjklmnpqrstuvwxyz23456789"
OpaqueId.generate(size: 8, alphabet: safe_alphabet)
# => "ABCDEFGH"

# Filesystem safe (63 characters)
filesystem_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
OpaqueId.generate(size: 12, alphabet: filesystem_alphabet)
# => "V1StGXR8_Z5jd"

# Base64-like (64 characters)
base64_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
OpaqueId.generate(size: 16, alphabet: base64_alphabet)
# => "V1StGXR8/Z5jdHi6B"
```

### Alphabet Selection Guide

**Choose `ALPHANUMERIC_ALPHABET` when:**

- Building APIs or web services
- IDs will be user-visible
- You need maximum compatibility
- General-purpose ID generation

**Choose `STANDARD_ALPHABET` when:**

- Building high-performance applications
- Creating short URLs or links
- You need maximum entropy
- File names or paths are involved

**Create custom alphabets when:**

- You need specific character sets
- Avoiding certain characters (0/O, 1/I/l)
- Working with legacy systems
- Special formatting requirements

## Algorithm Details

OpaqueId implements two optimized algorithms for secure ID generation, automatically selecting the best approach based on alphabet size:

### Fast Path Algorithm (64-character alphabets)

When using 64-character alphabets (like `STANDARD_ALPHABET`), OpaqueId uses an optimized bitwise approach:

```ruby
# Simplified algorithm for 64-character alphabets
def generate_fast(size, alphabet)
  result = ""
  size.times do
    # Get random byte from SecureRandom
    byte = SecureRandom.random_number(256)
    # Use bitwise AND to get index 0-63
    index = byte & 63
    result << alphabet[index]
  end
  result
end
```

**Advantages:**

- ⚡ **Maximum Performance**: Direct bitwise operations, no rejection sampling
- 🎯 **Perfect Distribution**: Each character has exactly 1/64 probability
- 🔒 **Cryptographically Secure**: Uses `SecureRandom` as entropy source
- 📊 **Predictable Performance**: Constant time complexity O(n)

**Why 64 characters?**

- 64 = 2^6, allowing efficient bitwise operations
- `byte & 63` extracts exactly 6 bits (0-63 range)
- No modulo bias since 256 is divisible by 64

### Unbiased Path Algorithm (other alphabets)

For alphabets with sizes other than 64, OpaqueId uses rejection sampling:

```ruby
# Simplified algorithm for non-64-character alphabets
def generate_unbiased(size, alphabet, alphabet_size)
  result = ""
  size.times do
    loop do
      # Get random byte
      byte = SecureRandom.random_number(256)
      # Calculate index using modulo
      index = byte % alphabet_size
      # Check if within unbiased range
      if byte < (256 / alphabet_size) * alphabet_size
        result << alphabet[index]
        break
      end
      # Reject and try again (rare occurrence)
    end
  end
  result
end
```

**Advantages:**

- 🎯 **Perfect Uniformity**: Eliminates modulo bias through rejection sampling
- 🔒 **Cryptographically Secure**: Uses `SecureRandom` as entropy source
- 🔧 **Flexible**: Works with any alphabet size
- 📈 **Statistically Sound**: Mathematically proven unbiased distribution

**Rejection Sampling Explained:**

- When `byte % alphabet_size` would create bias, the byte is rejected
- Only bytes in the "unbiased range" are used
- Rejection rate is minimal (typically <1% for common alphabet sizes)

### Algorithm Selection

```ruby
def generate(size:, alphabet:)
  alphabet_size = alphabet.size

  if alphabet_size == 64
    generate_fast(size, alphabet)      # Fast path
  else
    generate_unbiased(size, alphabet, alphabet_size)  # Unbiased path
  end
end
```

## Performance Characteristics

OpaqueId is designed for efficient ID generation with different performance characteristics based on alphabet size:

- **64-character alphabets**: Use optimized bitwise operations for faster generation
- **Other alphabets**: Use rejection sampling for unbiased distribution with slight overhead
- **Memory usage**: Scales linearly with ID length
- **Collision resistance**: Extremely low probability for typical use cases

### Performance Characteristics

#### Fast Path (64-character alphabets)

- **Time Complexity**: O(n) where n = ID length
- **Space Complexity**: O(n)
- **Rejection Rate**: 0% (no rejections)
- **Distribution**: Uniform distribution
- **Best For**: High-performance applications, short URLs

#### Unbiased Path (other alphabets)

- **Time Complexity**: O(n × (1 + rejection_rate)) where rejection_rate ≈ 0.01
- **Space Complexity**: O(n)
- **Rejection Rate**: <1% for most alphabet sizes
- **Distribution**: Uniform distribution using rejection sampling
- **Best For**: General-purpose applications, custom alphabets

### Real-World Performance

```ruby
# Benchmark example
require 'benchmark'

# Fast path (STANDARD_ALPHABET - 64 characters)
Benchmark.measure do
  1_000_000.times { OpaqueId.generate(size: 21, alphabet: OpaqueId::STANDARD_ALPHABET) }
end
# => 0.400000 seconds

# Unbiased path (ALPHANUMERIC_ALPHABET - 62 characters)
Benchmark.measure do
  1_000_000.times { OpaqueId.generate(size: 21, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET) }
end
# => 0.830000 seconds
```

### Performance Optimization Tips

1. **Use 64-character alphabets** when possible for maximum speed
2. **Prefer `STANDARD_ALPHABET`** over `ALPHANUMERIC_ALPHABET` for performance-critical applications
3. **Batch generation** is more efficient than individual calls
4. **Avoid very small alphabets** (2-10 characters) for high-volume applications
5. **Consider ID length** - longer IDs take proportionally more time

## Error Handling

```ruby
# Invalid size
OpaqueId.generate(size: 0)
# => raises OpaqueId::ConfigurationError

# Empty alphabet
OpaqueId.generate(alphabet: "")
# => raises OpaqueId::ConfigurationError

# Collision resolution failure
# => raises OpaqueId::GenerationError after max retry attempts
```

## Security Considerations

### Cryptographic Security

OpaqueId is designed with security as a primary concern:

- **🔒 Cryptographically Secure**: Uses Ruby's `SecureRandom` for entropy generation
- **🎯 Unbiased Distribution**: Implements rejection sampling to eliminate modulo bias
- **🚫 Non-Sequential**: IDs are unpredictable and don't reveal creation order
- **🔄 Collision Resistant**: Automatic collision detection and resolution
- **📊 Statistically Sound**: Mathematically proven uniform distribution

### Security Best Practices

#### ✅ **DO Use OpaqueId For:**

- **Public-facing identifiers** (user IDs, post IDs, order numbers)
- **API keys and authentication tokens**
- **Session identifiers and CSRF tokens**
- **File upload names and temporary URLs**
- **Webhook signatures and verification tokens**
- **Database migration identifiers**
- **Cache keys and job identifiers**

#### ❌ **DON'T Use OpaqueId For:**

- **Passwords or password hashes** (use proper password hashing)
- **Encryption keys** (use dedicated key generation libraries)
- **Sensitive data** (IDs are not encrypted, just opaque)
- **Sequential operations** (where order matters)
- **Very short IDs** (less than 8 characters for security-critical use cases)

### Security Recommendations

#### ID Length Guidelines

| Use Case           | Minimum Length | Recommended Length | Reasoning                       |
| ------------------ | -------------- | ------------------ | ------------------------------- |
| **Public URLs**    | 8 characters   | 12-16 characters   | Balance security vs. URL length |
| **API Keys**       | 16 characters  | 21+ characters     | High security requirements      |
| **Session Tokens** | 21 characters  | 21+ characters     | Standard security practice      |
| **File Names**     | 8 characters   | 12+ characters     | Prevent enumeration attacks     |
| **Database IDs**   | 12 characters  | 16+ characters     | Long-term security              |

#### Alphabet Selection for Security

- **`STANDARD_ALPHABET`**: Best for high-security applications (64 characters = 6 bits entropy per character)
- **`ALPHANUMERIC_ALPHABET`**: Good for general use (62 characters = ~5.95 bits entropy per character)
- **Custom alphabets**: Avoid very small alphabets (< 16 characters) for security-critical use cases

#### Entropy Calculations

For 21-character IDs:

- **STANDARD_ALPHABET**: 2^126 ≈ 8.5 × 10^37 possible combinations
- **ALPHANUMERIC_ALPHABET**: 2^124 ≈ 2.1 × 10^37 possible combinations
- **Numeric (0-9)**: 2^70 ≈ 1.2 × 10^21 possible combinations

### Threat Model Considerations

#### Information Disclosure

- **✅ OpaqueId prevents**: Sequential ID enumeration, creation time inference
- **⚠️ OpaqueId doesn't prevent**: ID guessing (use proper authentication)

#### Brute Force Attacks

- **Protection**: Extremely large ID space makes brute force impractical
- **Recommendation**: Combine with rate limiting and authentication

#### Timing Attacks

- **Protection**: Constant-time generation algorithms
- **Recommendation**: Use consistent ID lengths to prevent timing analysis

### Security Audit Checklist

When implementing OpaqueId in security-critical applications:

- [ ] **ID Length**: Using appropriate length for threat model
- [ ] **Alphabet Choice**: Using alphabet with sufficient entropy
- [ ] **Collision Handling**: Proper error handling for rare collisions
- [ ] **Rate Limiting**: Implementing rate limits on ID-based endpoints
- [ ] **Authentication**: Proper authentication before ID-based operations
- [ ] **Logging**: Not logging sensitive IDs in plain text
- [ ] **Database Indexing**: Proper indexing for performance and security
- [ ] **Error Messages**: Not revealing ID existence in error messages

## Use Cases

### E-Commerce Applications

#### Order Management

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Generate secure order numbers
  opaque_id_length 16
  opaque_id_alphabet OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
order = Order.create!(customer_id: 123, total: 99.99)
# => #<Order id: 1, opaque_id: "K8mN2pQ7rS9tU3vW", ...>

# Public-facing order tracking
# https://store.com/orders/K8mN2pQ7rS9tU3vW
```

#### Product Catalog

```ruby
class Product < ApplicationRecord
  include OpaqueId::Model

  # Shorter IDs for product URLs
  opaque_id_length 12
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
product = Product.create!(name: "Wireless Headphones", price: 199.99)
# => #<Product id: 1, opaque_id: "aB3dE6fG9hI", ...>

# SEO-friendly product URLs
# https://store.com/products/aB3dE6fG9hI
```

### API Development

#### API Key Management

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Long, secure API keys
  opaque_id_length 32
  opaque_id_alphabet OpaqueId::ALPHANUMERIC_ALPHABET
  opaque_id_require_letter_start true  # Start with letter for readability
end

# Usage
api_key = ApiKey.create!(user_id: 123, name: "Production API")
# => #<ApiKey id: 1, opaque_id: "K8mN2pQ7rS9tU3vW5xY1zA4bC6dE8fG", ...>

# API authentication
# Authorization: Bearer K8mN2pQ7rS9tU3vW5xY1zA4bC6dE8fG
```

#### Webhook Signatures

```ruby
class WebhookEvent < ApplicationRecord
  include OpaqueId::Model

  # Unique event identifiers
  opaque_id_length 21
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
event = WebhookEvent.create!(
  event_type: "payment.completed",
  payload: { order_id: "K8mN2pQ7rS9tU3vW" }
)
# => #<WebhookEvent id: 1, opaque_id: "aB3dE6fG9hI2jK5lM8nP", ...>

# Webhook delivery
# POST https://client.com/webhooks
# X-Event-ID: aB3dE6fG9hI2jK5lM8nP
```

### Content Management Systems

#### Blog Posts

```ruby
class Post < ApplicationRecord
  include OpaqueId::Model

  # Medium-length IDs for blog URLs
  opaque_id_length 14
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
post = Post.create!(title: "Getting Started with OpaqueId", content: "...")
# => #<Post id: 1, opaque_id: "aB3dE6fG9hI2jK", ...>

# Clean blog URLs
# https://blog.com/posts/aB3dE6fG9hI2jK
```

#### File Uploads

```ruby
class Attachment < ApplicationRecord
  include OpaqueId::Model

  # Secure file identifiers
  opaque_id_length 16
  opaque_id_alphabet OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
attachment = Attachment.create!(
  filename: "document.pdf",
  content_type: "application/pdf"
)
# => #<Attachment id: 1, opaque_id: "K8mN2pQ7rS9tU3vW", ...>

# Secure file access
# https://cdn.example.com/files/K8mN2pQ7rS9tU3vW
```

### User Management

#### User Profiles

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Public user identifiers
  opaque_id_length 12
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
user = User.create!(email: "user@example.com", name: "John Doe")
# => #<User id: 1, opaque_id: "aB3dE6fG9hI2", ...>

# Public profile URLs
# https://social.com/users/aB3dE6fG9hI2
```

#### Session Management

```ruby
class Session < ApplicationRecord
  include OpaqueId::Model

  # Secure session tokens
  opaque_id_length 21
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
session = Session.create!(user_id: 123, expires_at: 1.week.from_now)
# => #<Session id: 1, opaque_id: "aB3dE6fG9hI2jK5lM8nP", ...>

# Session cookie
# session_token=aB3dE6fG9hI2jK5lM8nP
```

### Background Job Systems

#### Job Tracking

```ruby
class Job < ApplicationRecord
  include OpaqueId::Model

  # Unique job identifiers
  opaque_id_length 18
  opaque_id_alphabet OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
job = Job.create!(
  job_type: "email_delivery",
  status: "pending",
  payload: { user_id: 123, template: "welcome" }
)
# => #<Job id: 1, opaque_id: "K8mN2pQ7rS9tU3vW5x", ...>

# Job status API
# GET /api/jobs/K8mN2pQ7rS9tU3vW5x/status
```

### Short URL Services

#### URL Shortening

```ruby
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  # Very short IDs for URL shortening
  opaque_id_length 6
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
short_url = ShortUrl.create!(
  original_url: "https://very-long-url.com/path/to/resource",
  user_id: 123
)
# => #<ShortUrl id: 1, opaque_id: "aB3dE6", ...>

# Short URL
# https://short.ly/aB3dE6
```

### Real-Time Applications

#### Chat Rooms

```ruby
class ChatRoom < ApplicationRecord
  include OpaqueId::Model

  # Medium-length room identifiers
  opaque_id_length 10
  opaque_id_alphabet OpaqueId::STANDARD_ALPHABET
end

# Usage
room = ChatRoom.create!(name: "General Discussion", owner_id: 123)
# => #<ChatRoom id: 1, opaque_id: "aB3dE6fG9h", ...>

# WebSocket connection
# ws://chat.example.com/rooms/aB3dE6fG9h
```

### Analytics and Tracking

#### Event Tracking

```ruby
class AnalyticsEvent < ApplicationRecord
  include OpaqueId::Model

  # Unique event identifiers
  opaque_id_length 20
  opaque_id_alphabet OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
event = AnalyticsEvent.create!(
  event_type: "page_view",
  user_id: 123,
  properties: { page: "/products", referrer: "google.com" }
)
# => #<AnalyticsEvent id: 1, opaque_id: "K8mN2pQ7rS9tU3vW5xY1", ...>

# Event tracking pixel
# <img src="/track/K8mN2pQ7rS9tU3vW5xY1" />
```

### Use Case Summary

| Use Case            | ID Length | Alphabet     | Reasoning                        |
| ------------------- | --------- | ------------ | -------------------------------- |
| **Order Numbers**   | 16 chars  | Alphanumeric | Balance security vs. readability |
| **Product URLs**    | 12 chars  | Standard     | SEO-friendly, secure             |
| **API Keys**        | 32 chars  | Alphanumeric | High security, letter start      |
| **Webhook Events**  | 21 chars  | Standard     | Standard security practice       |
| **Blog Posts**      | 14 chars  | Standard     | Clean URLs, good security        |
| **File Uploads**    | 16 chars  | Alphanumeric | Secure, collision-resistant      |
| **User Profiles**   | 12 chars  | Standard     | Public-facing, secure            |
| **Sessions**        | 21 chars  | Standard     | High security requirement        |
| **Background Jobs** | 18 chars  | Alphanumeric | Unique, trackable                |
| **Short URLs**      | 6 chars   | Standard     | Very short, still secure         |
| **Chat Rooms**      | 10 chars  | Standard     | Medium length, secure            |
| **Analytics**       | 20 chars  | Alphanumeric | Unique, high volume              |

## Development

### Prerequisites

- **Ruby**: 3.2.0 or higher
- **Rails**: 8.0 or higher (for generator testing)
- **Bundler**: Latest version

### Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/nyaggah/opaque_id.git
   cd opaque_id
   ```

2. **Install dependencies**:

   ```bash
   bundle install
   ```

3. **Run the setup script**:
   ```bash
   bin/setup
   ```

### Development Commands

#### Testing

```bash
# Run all tests
bundle exec rake test

# Run specific test files
bundle exec ruby -Itest test/opaque_id_test.rb
bundle exec ruby -Itest test/opaque_id/model_test.rb
bundle exec ruby -Itest test/opaque_id/generators/install_generator_test.rb

# Run tests with verbose output
bundle exec rake test TESTOPTS="--verbose"
```

#### Code Quality

```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-correct RuboCop offenses
bundle exec rubocop -a

# Run RuboCop on specific files
bundle exec rubocop lib/opaque_id.rb
```

#### Interactive Development

```bash
# Start interactive console
bin/console

# Example usage in console:
# OpaqueId.generate
# OpaqueId.generate(size: 10, alphabet: OpaqueId::STANDARD_ALPHABET)
```

#### Local Installation

```bash
# Install gem locally for testing
bundle exec rake install

# Uninstall local version
gem uninstall opaque_id
```

### Project Structure

```
opaque_id/
├── lib/
│   ├── opaque_id.rb              # Main module and core functionality
│   ├── opaque_id/
│   │   ├── model.rb              # ActiveRecord concern
│   │   └── version.rb            # Version constant
│   └── generators/
│       └── opaque_id/
│           ├── install_generator.rb
│           └── templates/
│               └── migration.rb.tt
├── test/
│   ├── opaque_id_test.rb         # Core module tests
│   ├── opaque_id/
│   │   ├── model_test.rb         # Model concern tests
│   │   └── generators/
│   │       └── install_generator_test.rb
│   └── test_helper.rb            # Test configuration
├── tasks/                        # Project management and documentation
├── opaque_id.gemspec            # Gem specification
├── Gemfile                      # Development dependencies
├── Rakefile                     # Rake tasks
└── README.md                    # This file
```

### Testing Strategy

#### Test Coverage

- **Core Module**: ID generation, error handling, edge cases
- **ActiveRecord Integration**: Model callbacks, finder methods, configuration
- **Rails Generator**: Migration generation, model modification
- **Performance**: Statistical uniformity, benchmark tests
- **Error Handling**: Invalid inputs, collision scenarios

#### Test Database

- Uses in-memory SQLite for fast, isolated testing
- No external database dependencies
- Automatic cleanup between tests

### Release Process

#### Version Management

1. **Update version** in `lib/opaque_id/version.rb`
2. **Update CHANGELOG.md** with new features/fixes
3. **Run tests** to ensure everything works
4. **Commit changes** with conventional commit message
5. **Create release** using rake task

#### Release Commands

```bash
# Build and release gem
bundle exec rake release

# This will:
# 1. Build the gem
# 2. Create a git tag
# 3. Push to GitHub
# 4. Push to RubyGems
```

### Development Guidelines

#### Code Style

- Follow RuboCop configuration
- Use conventional commit messages
- Write comprehensive tests for new features
- Document public APIs with examples

#### Git Workflow

- Use feature branches for development
- Write descriptive commit messages
- Keep commits focused and atomic
- Test before committing

#### Performance Considerations

- Benchmark new features
- Consider memory usage for high-volume scenarios
- Test with various alphabet sizes
- Validate statistical properties

## Contributing

### Reporting Issues

We welcome bug reports and feature requests! Please help us improve OpaqueId by reporting issues on GitHub:

- **🐛 Bug Reports**: [Create an issue](https://github.com/nyaggah/opaque_id/issues/new?template=bug_report.md)
- **💡 Feature Requests**: [Create an issue](https://github.com/nyaggah/opaque_id/issues/new?template=feature_request.md)
- **📖 Documentation**: [Create an issue](https://github.com/nyaggah/opaque_id/issues/new?template=documentation.md)

### Issue Guidelines

When reporting issues, please include:

#### For Bug Reports

- **Ruby version**: `ruby --version`
- **Rails version**: `rails --version` (if applicable)
- **OpaqueId version**: `gem list opaque_id`
- **Steps to reproduce**: Clear, minimal steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Error messages**: Full error output
- **Code example**: Minimal code that reproduces the issue

#### For Feature Requests

- **Use case**: Why is this feature needed?
- **Proposed solution**: How should it work?
- **Alternatives considered**: What other approaches were considered?
- **Additional context**: Any other relevant information

### Code of Conduct

This project is intended to be a safe, welcoming space for collaboration. Everyone interacting in the OpaqueId project's codebases, issue trackers, and community spaces is expected to follow the [Code of Conduct](https://github.com/nyaggah/opaque_id/blob/main/CODE_OF_CONDUCT.md).

### Community Guidelines

- **Be respectful**: Treat everyone with respect and kindness
- **Be constructive**: Provide helpful feedback and suggestions
- **Be patient**: Maintainers are volunteers with limited time
- **Be specific**: Provide clear, detailed information in issues
- **Be collaborative**: Work together to solve problems

### Getting Help

- **Documentation**: Check this README and inline code documentation
- **Issues**: Search existing issues before creating new ones
- **Discussions**: Use GitHub Discussions for questions and general discussion

## License

OpaqueId is released under the **MIT License**. This is a permissive open source license that allows you to use, modify, and distribute the software with minimal restrictions.

### License Summary

**You are free to:**

- ✅ Use OpaqueId in commercial and non-commercial projects
- ✅ Modify the source code to suit your needs
- ✅ Distribute copies of the software
- ✅ Include OpaqueId in proprietary applications
- ✅ Sell products that include OpaqueId

**You must:**

- 📋 Include the original copyright notice and license text
- 📋 Include the license in any distribution of the software

**You are not required to:**

- ❌ Share your modifications (though contributions are welcome)
- ❌ Use the same license for your project
- ❌ Provide source code for your application

### Full License Text

The complete MIT License text is available in the [LICENSE.txt](LICENSE.txt) file in this repository.

### License Compatibility

The MIT License is compatible with:

- **GPL**: Can be included in GPL projects
- **Apache 2.0**: Compatible with Apache-licensed projects
- **BSD**: Compatible with BSD-licensed projects
- **Commercial**: Can be used in proprietary, commercial software

### Copyright

Copyright (c) 2025 Joey Doey. All rights reserved.

### Third-Party Licenses

OpaqueId uses the following dependencies:

- **ActiveRecord**: MIT License
- **ActiveSupport**: MIT License
- **SecureRandom**: Part of Ruby standard library (Ruby License)

### Legal Disclaimer

This software is provided "as is" without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.

## Code of Conduct

Everyone interacting in the OpaqueId project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nyaggah/opaque_id/blob/main/CODE_OF_CONDUCT.md).

## Acknowledgements

OpaqueId is heavily inspired by [nanoid.rb](https://github.com/radeno/nanoid.rb), which is a Ruby implementation of the original [NanoID](https://github.com/ai/nanoid) project. The core algorithm and approach to secure ID generation draws from the excellent work done by the NanoID team.

The motivation and use case for OpaqueId was inspired by the insights shared in ["Why we chose NanoIDs for PlanetScale's API"](https://planetscale.com/blog/why-we-chose-nanoids-for-planetscales-api) by Mike Coutermarsh, which highlights the benefits of using opaque, non-sequential identifiers in modern web applications.

We're grateful to the open source community for these foundational contributions that made OpaqueId possible.
