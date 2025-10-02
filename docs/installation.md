---
layout: default
title: Installation
nav_order: 3
description: "Complete installation guide for OpaqueId with all methods and troubleshooting"
permalink: /installation/
---

# Installation

This guide covers all installation methods for OpaqueId, from basic setup to advanced configurations.

## Requirements

Before installing OpaqueId, ensure your environment meets these requirements:

### System Requirements

- **Ruby 3.2+** - OpaqueId uses modern Ruby features and requires Ruby 3.2 or higher
- **Rails 8.0+** - Built specifically for Rails 8.0 and later versions
- **ActiveRecord 8.0+** - For model integration and generator functionality

### Database Requirements

- **Any ActiveRecord-supported database** - SQLite, PostgreSQL, MySQL, etc.
- **Database permissions** - Ability to create tables and indexes

## Installation Methods

### Method 1: Using Bundler (Recommended)

This is the recommended approach for Rails applications.

#### Step 1: Add to Gemfile

Add OpaqueId to your application's Gemfile:

```ruby
# Gemfile
gem 'opaque_id'
```

#### Step 2: Install Dependencies

Run bundle install to install the gem and its dependencies:

```bash
bundle install
```

#### Step 3: Generate Setup

Use the Rails generator to set up OpaqueId for your models:

```bash
# For a User model
rails generate opaque_id:install User

# For multiple models
rails generate opaque_id:install User
rails generate opaque_id:install Post
rails generate opaque_id:install Comment
```

#### Step 4: Run Migrations

Execute the generated migrations:

```bash
rails db:migrate
```

### Method 2: Manual Installation

If you prefer manual installation or need more control over the setup process.

#### Step 1: Install the Gem

```bash
gem install opaque_id
```

#### Step 2: Create Migration Manually

Create a migration file:

```bash
rails generate migration AddOpaqueIdToUsers opaque_id:string:uniq
```

#### Step 3: Edit Migration

Update the migration file:

```ruby
# db/migrate/YYYYMMDDHHMMSS_add_opaque_id_to_users.rb
class AddOpaqueIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :opaque_id, :string
    add_index :users, :opaque_id, unique: true
  end
end
```

#### Step 4: Update Model

Manually include the concern in your model:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include OpaqueId::Model
end
```

#### Step 5: Run Migration

```bash
rails db:migrate
```

### Method 3: From Source

For development or if you need the latest features.

#### Step 1: Clone Repository

```bash
git clone https://github.com/nyaggah/opaque_id.git
cd opaque_id
```

#### Step 2: Build and Install

```bash
gem build opaque_id.gemspec
gem install opaque_id-*.gem
```

#### Step 3: Add to Gemfile

```ruby
# Gemfile
gem 'opaque_id', path: '/path/to/opaque_id'
```

#### Step 4: Install Dependencies

```bash
bundle install
```

## Generator Options

The Rails generator supports several options for customization:

### Basic Usage

```bash
rails generate opaque_id:install ModelName
```

### Custom Column Name

```bash
rails generate opaque_id:install User --column-name=public_id
```

This will:

- Create a `public_id` column instead of `opaque_id`
- Add `self.opaque_id_column = :public_id` to your model

### Multiple Models

```bash
rails generate opaque_id:install User
rails generate opaque_id:install Post --column-name=slug
rails generate opaque_id:install Comment
```

## Post-Installation Setup

### Verify Installation

Check that everything is working correctly:

```ruby
# In Rails console
rails console

# Test basic functionality
user = User.create!(name: "Test User")
puts user.opaque_id
# => Should output a 21-character alphanumeric string

# Test finder methods
found_user = User.find_by_opaque_id(user.opaque_id)
puts found_user.name
# => "Test User"
```

### Configure Global Settings (Optional)

Create an initializer for global configuration:

```ruby
# config/initializers/opaque_id.rb
OpaqueId.configure do |config|
  config.default_length = 15
  config.default_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

## Troubleshooting

### Common Installation Issues

#### Issue: Generator Not Found

**Error**: `Could not find generator 'opaque_id:install'`

**Solution**: Ensure the gem is properly installed and bundled:

```bash
bundle install
bundle exec rails generate opaque_id:install User
```

#### Issue: Migration Fails

**Error**: `ActiveRecord::StatementInvalid` or similar database errors

**Solution**: Check your database permissions and Rails version:

```bash
# Check Rails version
rails --version

# Check database connection
rails db:version
```

#### Issue: Model Not Updated

**Error**: Generator runs but model file isn't updated

**Solution**: Check file permissions and ensure the model file exists:

```bash
# Check if model file exists
ls app/models/user.rb

# Check file permissions
ls -la app/models/user.rb
```

#### Issue: Bundle Install Fails

**Error**: Dependency conflicts or version issues

**Solution**: Update your Gemfile and run bundle update:

```bash
bundle update
bundle install
```

### Version Compatibility

#### Ruby Version Issues

If you're using an older Ruby version:

```bash
# Check Ruby version
ruby --version

# Update Ruby (using rbenv)
rbenv install 3.2.0
rbenv local 3.2.0
```

#### Rails Version Issues

If you're using an older Rails version:

```bash
# Check Rails version
rails --version

# Update Rails
bundle update rails
```

### Database-Specific Issues

#### PostgreSQL

Ensure you have the correct PostgreSQL adapter:

```ruby
# Gemfile
gem 'pg', '~> 1.1'
```

#### MySQL

Ensure you have the correct MySQL adapter:

```ruby
# Gemfile
gem 'mysql2', '~> 0.5'
```

#### SQLite

SQLite should work out of the box with Rails:

```ruby
# Gemfile
gem 'sqlite3', '~> 1.4'
```

## Uninstallation

If you need to remove OpaqueId from your application:

### Step 1: Remove from Gemfile

```ruby
# Gemfile
# gem 'opaque_id'  # Comment out or remove this line
```

### Step 2: Remove Dependencies

```bash
bundle install
```

### Step 3: Remove Migrations (Optional)

If you want to remove the opaque_id columns:

```bash
rails generate migration RemoveOpaqueIdFromUsers opaque_id:string
rails db:migrate
```

### Step 4: Remove Model Code

Remove the include statement from your models:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # include OpaqueId::Model  # Comment out or remove this line
end
```

## Next Steps

After successful installation:

1. **Read the [Getting Started Guide](getting-started.md)** for basic usage
2. **Explore [Configuration](configuration.md)** for advanced setup
3. **Check out [Use Cases](use-cases.md)** for real-world usage patterns
4. **Review [API Reference](api-reference.md)** for complete documentation

## Support

If you encounter issues during installation:

1. **Check the troubleshooting section** above
2. **Review the [GitHub Issues](https://github.com/nyaggah/opaque_id/issues)** for similar problems
3. **Open a new issue** with details about your environment and the error
