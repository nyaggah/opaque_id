---
layout: default
title: Development
nav_order: 11
description: "Development setup, guidelines, and contribution information"
permalink: /development/
---

# Development

This guide covers development setup, guidelines, and contribution information for OpaqueId. Whether you're contributing to the project or developing applications that use OpaqueId, this guide will help you get started.

- TOC
{:toc}

## Prerequisites

Before you begin development, ensure you have the following installed:

### Required Software

- **Ruby 3.2+** - OpaqueId requires modern Ruby features
- **Rails 8.0+** - For testing and development
- **Git** - For version control
- **Bundler** - For dependency management

### Development Tools

- **Text Editor/IDE** - VS Code, RubyMine, or your preferred editor
- **Terminal** - For running commands and tests
- **Database** - SQLite (for testing), PostgreSQL or MySQL (for production)

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/nyaggah/opaque_id.git
cd opaque_id
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Run Tests

```bash
bundle exec rake test
```

### 4. Run Code Quality Checks

```bash
bundle exec rubocop
bundle exec bundle audit --update
```

## Development Commands

### Testing

```bash
# Run all tests
bundle exec rake test

# Run specific test files
bundle exec ruby test/opaque_id_test.rb
bundle exec ruby test/opaque_id/model_test.rb
bundle exec ruby test/opaque_id/generators/install_generator_test.rb

# Run tests with verbose output
bundle exec rake test VERBOSE=true

# Run tests with coverage
bundle exec rake test COVERAGE=true
```

### Code Quality

```bash
# Run RuboCop
bundle exec rubocop

# Auto-correct RuboCop offenses
bundle exec rubocop --autocorrect

# Run security audit
bundle exec bundle audit --update

# Check for outdated dependencies
bundle outdated
```

### Console

```bash
# Start Rails console with OpaqueId loaded
bundle exec rails console

# Test OpaqueId functionality
OpaqueId.generate
OpaqueId.generate(size: 10)
OpaqueId.generate(alphabet: OpaqueId::STANDARD_ALPHABET)
```

### Local Installation

```bash
# Build the gem
gem build opaque_id.gemspec

# Install locally
gem install opaque_id-*.gem

# Or install from local path
gem install --local opaque_id-*.gem
```

## Project Structure

```
opaque_id/
├── lib/
│   ├── opaque_id.rb              # Main module
│   ├── opaque_id/
│   │   ├── model.rb              # ActiveRecord concern
│   │   └── version.rb            # Version information
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
├── docs/                         # Documentation site
├── tasks/                        # Task lists and PRDs
├── .github/
│   └── workflows/                # GitHub Actions
├── Gemfile                       # Development dependencies
├── opaque_id.gemspec            # Gem specification
├── Rakefile                     # Rake tasks
└── README.md                    # Project documentation
```

## Testing Strategy

### Test Coverage

OpaqueId maintains comprehensive test coverage across all components:

- **Core Module Tests** - ID generation, error handling, edge cases
- **Model Tests** - ActiveRecord integration, configuration, finder methods
- **Generator Tests** - Rails generator functionality, file generation
- **Statistical Tests** - Uniformity and randomness verification
- **Performance Tests** - Benchmarking and optimization validation

### Test Categories

#### Unit Tests

```ruby
# test/opaque_id_test.rb
class OpaqueIdTest < Minitest::Test
  def test_generate_default_parameters
    id = OpaqueId.generate
    assert_equal 21, id.length
    assert_match(/\A[A-Za-z0-9]+\z/, id)
  end

  def test_generate_custom_parameters
    id = OpaqueId.generate(size: 10, alphabet: OpaqueId::STANDARD_ALPHABET)
    assert_equal 10, id.length
    assert_match(/\A[A-Za-z0-9_-]+\z/, id)
  end
end
```

#### Integration Tests

```ruby
# test/opaque_id/model_test.rb
class ModelTest < Minitest::Test
  def test_automatic_id_generation
    user = User.create!(name: "John Doe")
    assert_not_nil user.opaque_id
    assert_equal 21, user.opaque_id.length
  end

  def test_finder_methods
    user = User.create!(name: "Jane Smith")
    found_user = User.find_by_opaque_id(user.opaque_id)
    assert_equal user, found_user
  end
end
```

#### Generator Tests

```ruby
# test/opaque_id/generators/install_generator_test.rb
class InstallGeneratorTest < Minitest::Test
  def test_generator_creates_migration
    generator = create_generator('User')
    generator.invoke_all

    assert File.exist?('db/migrate/*_add_opaque_id_to_users.rb')
  end

  def test_generator_updates_model
    generator = create_generator('User')
    generator.invoke_all

    model_content = File.read('app/models/user.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end
end
```

### Statistical Testing

```ruby
def test_statistical_uniformity
  # Generate large sample of IDs
  sample_size = 10000
  ids = sample_size.times.map { OpaqueId.generate }

  # Analyze character distribution
  all_chars = ids.join.chars
  char_counts = all_chars.tally

  # Verify uniform distribution
  expected_count = all_chars.size / OpaqueId::ALPHANUMERIC_ALPHABET.size
  char_counts.each_value do |count|
    assert_in_delta expected_count, count, expected_count * 0.3
  end
end
```

## Release Process

### Version Management

OpaqueId uses semantic versioning (SemVer) with automated release management:

- **Major Version** - Breaking changes
- **Minor Version** - New features, backward compatible
- **Patch Version** - Bug fixes, backward compatible

### Release Workflow

1. **Development** - Work on feature branches
2. **Testing** - Comprehensive test suite
3. **Code Review** - Pull request review process
4. **Release** - Automated via GitHub Actions
5. **Publishing** - Automatic gem publishing to RubyGems.org

### Release Steps

```bash
# 1. Update version in lib/opaque_id/version.rb
# 2. Update CHANGELOG.md
# 3. Create release commit
git add .
git commit -m "Release v1.0.0"

# 4. Create and push tag
git tag v1.0.0
git push origin v1.0.0

# 5. GitHub Actions handles the rest:
# - Builds the gem
# - Publishes to RubyGems.org
# - Creates GitHub release
```

## Development Guidelines

### Code Style

OpaqueId follows Ruby community standards:

- **RuboCop** - Automated code style enforcement
- **Minitest** - Testing framework
- **Conventional Commits** - Commit message format
- **Documentation** - Comprehensive inline documentation

### Commit Messages

Use conventional commit format:

```
feat: add support for custom alphabets
fix: resolve collision handling edge case
docs: update installation instructions
test: add statistical uniformity tests
refactor: optimize fast path algorithm
```

### Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch
3. **Implement** your changes
4. **Add** tests for new functionality
5. **Update** documentation
6. **Run** the test suite
7. **Submit** a pull request

### Code Review Checklist

- [ ] Tests pass
- [ ] Code follows style guidelines
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance impact considered
- [ ] Backward compatibility maintained

## Contributing

### Issue Reporting

OpaqueId follows an "open source, closed contribution" model. We welcome:

- **Bug Reports** - Issues with existing functionality
- **Feature Requests** - New functionality suggestions
- **Documentation Improvements** - Better documentation

### Issue Guidelines

#### Bug Reports

When reporting bugs, include:

- **Ruby Version** - `ruby --version`
- **Rails Version** - `rails --version`
- **OpaqueId Version** - `gem list opaque_id`
- **Reproduction Steps** - Clear steps to reproduce
- **Expected Behavior** - What should happen
- **Actual Behavior** - What actually happens
- **Error Messages** - Full error messages and stack traces

#### Feature Requests

When requesting features, include:

- **Use Case** - Why is this feature needed?
- **Proposed Solution** - How should it work?
- **Alternatives** - Other solutions considered
- **Additional Context** - Any other relevant information

### Code of Conduct

OpaqueId follows the Contributor Covenant Code of Conduct:

- **Be Respectful** - Treat everyone with respect
- **Be Inclusive** - Welcome people of all backgrounds
- **Be Constructive** - Provide helpful feedback
- **Be Professional** - Maintain professional communication

### Community Guidelines

- **Ask Questions** - Use GitHub Issues for questions
- **Share Knowledge** - Help others learn
- **Report Issues** - Help improve the project
- **Follow Guidelines** - Respect project standards

## Getting Help

### Documentation

- **README.md** - Project overview and quick start
- **Documentation Site** - Comprehensive guides
- **API Reference** - Complete method documentation
- **Examples** - Real-world usage examples

### Support Channels

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and community discussion
- **Documentation** - Comprehensive guides and examples

### Common Issues

#### Installation Issues

```bash
# Ensure Ruby version compatibility
ruby --version  # Should be 3.2+

# Clear gem cache
gem cleanup

# Reinstall dependencies
bundle install --force
```

#### Test Failures

```bash
# Run tests with verbose output
bundle exec rake test VERBOSE=true

# Check test database
bundle exec rake db:test:prepare

# Clear test cache
bundle exec rake test:prepare
```

#### Generator Issues

```bash
# Check Rails version
rails --version  # Should be 8.0+

# Verify generator is available
rails generate opaque_id:install --help

# Check model file permissions
ls -la app/models/
```

## Development Environment

### Recommended Setup

#### VS Code

```json
// .vscode/settings.json
{
  "ruby.rubocop.executePath": "bundle exec",
  "ruby.format": "rubocop",
  "ruby.lint": {
    "rubocop": true
  },
  "files.associations": {
    "*.rb": "ruby",
    "*.gemspec": "ruby"
  }
}
```

#### RubyMine

- Enable RuboCop integration
- Configure test runner for Minitest
- Set up code formatting
- Enable version control integration

### Development Dependencies

```ruby
# Gemfile
group :development, :test do
  gem 'rake', '~> 13.3'
  gem 'sqlite3', '>= 2.1'
  gem 'rubocop', '~> 1.81'
  gem 'rails', '>= 8.0'
  gem 'bundle-audit', '~> 0.1'
end
```

### Environment Variables

```bash
# .env (for development)
RAILS_ENV=development
RUBY_VERSION=3.4.5
BUNDLE_GEMFILE=Gemfile
```

## Performance Development

### Benchmarking

```ruby
# Benchmark ID generation
require 'benchmark'

def benchmark_generation(count = 1000000)
  puts "Generating #{count} opaque IDs..."

  time = Benchmark.measure do
    count.times { OpaqueId.generate }
  end

  puts "Time: #{time.real.round(2)} seconds"
  puts "Rate: #{(count / time.real).round(0)} IDs/second"
end

# Run benchmark
benchmark_generation(1000000)
```

### Memory Profiling

```ruby
# Memory usage analysis
require 'memory_profiler'

def profile_memory(count = 100000)
  report = MemoryProfiler.report do
    count.times { OpaqueId.generate }
  end

  puts "Total allocated: #{report.total_allocated_memsize / 1024 / 1024}MB"
  puts "Total retained: #{report.total_retained_memsize / 1024 / 1024}MB"
end

# Run memory profile
profile_memory(100000)
```

### Load Testing

```ruby
# Concurrent generation testing
require 'concurrent'

def load_test(threads = 10, ids_per_thread = 100000)
  puts "Testing #{threads} threads, #{ids_per_thread} IDs each..."

  start_time = Time.now

  # Create thread pool
  pool = Concurrent::FixedThreadPool.new(threads)

  # Submit tasks
  futures = threads.times.map do
    pool.post do
      ids_per_thread.times.map { OpaqueId.generate }
    end
  end

  # Wait for completion
  results = futures.map(&:value!)

  end_time = Time.now
  total_ids = threads * ids_per_thread
  duration = end_time - start_time

  puts "Total IDs: #{total_ids}"
  puts "Duration: #{duration.round(2)} seconds"
  puts "Rate: #{(total_ids / duration).round(0)} IDs/second"

  pool.shutdown
  pool.wait_for_termination
end

# Run load test
load_test(10, 100000)
```

## Next Steps

Now that you understand development:

1. **Explore [API Reference](api-reference.md)** for complete method documentation
2. **Check out [Use Cases](use-cases.md)** for development examples
3. **Review [Configuration](configuration.md)** for development configuration
4. **Read [Security](security.md)** for security considerations
