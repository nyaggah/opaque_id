---
layout: default
title: Home
nav_order: 1
description: "Generate cryptographically secure, collision-free opaque IDs for ActiveRecord models"
permalink: /
---

# OpaqueId

[![Gem Version](https://badge.fury.io/rb/opaque_id.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/opaque_id)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)
[![Gem Downloads](https://img.shields.io/badge/gem%20downloads-opaque_id-blue)](https://rubygems.org/gems/opaque_id)

A simple Ruby gem for generating secure, opaque IDs for ActiveRecord models. OpaqueId provides a drop-in replacement for `nanoid.rb` using Ruby's built-in `SecureRandom` methods, with slug-like IDs as the default for optimal URL safety and user experience.

- TOC
  {:toc}

## Features

- **🔐 Cryptographically Secure**: Uses Ruby's `SecureRandom` for secure ID generation
- **⚡ High Performance**: Optimized algorithms with fast paths for 64-character alphabets
- **🎯 Collision-Free**: Built-in collision detection with configurable retry attempts
- **🔧 Highly Configurable**: Customizable alphabet, length, column name, and validation rules
- **🚀 Rails Integration**: Seamless ActiveRecord integration with automatic ID generation
- **📦 Rails Generator**: One-command setup with `rails generate opaque_id:install`
- **🧪 Well Tested**: Comprehensive test suite with statistical uniformity tests
- **📚 Rails 8.0+ Compatible**: Built for modern Rails applications

## Quick Start

### 1. Add to your Gemfile

```ruby
gem 'opaque_id'
```

### 2. Generate migration and update model

```bash
rails generate opaque_id:install User
```

### 3. Run migration

```bash
rails db:migrate
```

### 4. Use in your models

```ruby
class User < ApplicationRecord
  include OpaqueId::Model
end

# Create a user - opaque_id is automatically generated
user = User.create!(name: "John Doe")
puts user.opaque_id # => "izkpm55j334u8x9y2a"

# Find by opaque_id
user = User.find_by_opaque_id("izkpm55j334u8x9y2a")
```

## Why OpaqueId?

OpaqueId replaces the need for `nanoid.rb` by providing:

- **Native Ruby implementation** using `SecureRandom`
- **Better performance** with optimized algorithms
- **Rails 8.0+ compatibility** out of the box
- **ActiveRecord integration** with automatic ID generation
- **Collision handling** with configurable retry attempts
- **Flexible configuration** for different use cases

## Installation

### Requirements

- Ruby 3.2+
- Rails 8.0+
- ActiveRecord 8.0+

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

```bash
gem install opaque_id
```

## Getting Started

Ready to get started? Check out our [Getting Started Guide](getting-started.md) for a comprehensive walkthrough.

## Documentation

- [Getting Started](getting-started.md) - Quick setup and basic usage
- [Installation](installation.md) - Detailed installation guide
- [Usage](usage.md) - Comprehensive usage examples
- [Configuration](configuration.md) - All configuration options
- [Alphabets](alphabets.md) - Built-in alphabets and custom options
- [Algorithms](algorithms.md) - Technical algorithm details
- [Performance](performance.md) - Benchmarks and optimization tips
- [Security](security.md) - Security considerations and best practices
- [Use Cases](use-cases.md) - Real-world examples and applications
- [API Reference](api-reference.md) - Complete API documentation
- [Development](development.md) - Contributing and development setup

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

This project follows an "open source, closed contribution" model. We welcome bug reports, feature requests, and documentation improvements through GitHub Issues.

## Performance & Benchmarks

You can run benchmarks to test OpaqueId's performance and uniqueness characteristics on your system.

**Quick Test:**

```bash
# Test 10,000 ID generation
ruby -e "require 'opaque_id'; start=Time.now; 10000.times{OpaqueId.generate}; puts \"Generated 10,000 IDs in #{(Time.now-start).round(4)}s\""
```

**Expected Results:**

- **Performance**: 100,000+ IDs per second on modern hardware
- **Uniqueness**: Zero collisions in practice (theoretical probability < 10^-16 for 1M IDs)

For comprehensive benchmarks including collision tests, alphabet distribution analysis, and performance comparisons, see the [Benchmarks Guide](benchmarks.md).

## Acknowledgements

- [nanoid.rb](https://github.com/radeno/nanoid.rb) - Original inspiration and reference implementation
- [NanoID](https://github.com/ai/nanoid) - The original JavaScript implementation
- [PlanetScale Article](https://planetscale.com/blog/why-we-chose-nanoids-for-planetscales-api) by Mike Coutermarsh - Excellent explanation of opaque ID benefits
