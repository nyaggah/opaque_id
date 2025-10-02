# Task List: OpaqueId Ruby Gem Implementation

Based on PRD: `0001-prd-opaque-id-gem.md`

## Relevant Files

- `lib/opaque_id.rb` - Main module with core ID generation functionality and error classes
- `lib/opaque_id/version.rb` - Version constant (already exists)
- `lib/opaque_id/model.rb` - ActiveRecord concern for model integration
- `lib/generators/opaque_id/install_generator.rb` - Rails generator for migrations and model updates
- `lib/generators/opaque_id/templates/migration.rb.tt` - Migration template for generator
- `opaque_id.gemspec` - Gem specification and dependencies (updated for Rails 8.0+)
- `Gemfile` - Development dependencies
- `Rakefile` - Rake tasks for testing and linting
- `.rubocop.yml` - RuboCop configuration for code quality
- `test/test_helper.rb` - Test setup with Rails configuration and deprecation fixes
- `test/test_opaque_id.rb` - Unit tests for main module
- `test/opaque_id_test.rb` - Comprehensive tests for core functionality
- `test/opaque_id/model_test.rb` - Unit tests for ActiveRecord concern
- `test/opaque_id/generators/install_generator_test.rb` - Unit tests for generator
- `README.md` - Documentation and usage examples
- `CHANGELOG.md` - Version history and changes

### Notes

- Unit tests should be placed in the `test/` directory following Minitest conventions
- Use `ruby -Ilib:test test/test_opaque_id.rb` to run specific test files
- Use `rake test` to run all tests (once Rakefile is configured)
- The existing `test/test_helper.rb` already sets up Minitest and loads the gem

## Tasks

- [x] 1.0 Implement Core ID Generation Module

  - [x] 1.1 Create error classes (Error, GenerationError, ConfigurationError)
  - [x] 1.2 Implement alphabet constants (STANDARD_ALPHABET, ALPHANUMERIC_ALPHABET)
  - [x] 1.3 Implement generate_fast method for 64-character alphabets using bitwise operations
  - [x] 1.4 Implement generate_unbiased method with rejection sampling algorithm
  - [x] 1.5 Implement main generate method with parameter validation
  - [x] 1.6 Add proper error handling for invalid size and empty alphabet
  - [x] 1.7 Add require statements for SecureRandom and version

- [x] 2.0 Create ActiveRecord Model Integration

  - [x] 2.1 Create OpaqueId::Model concern with ActiveSupport::Concern
  - [x] 2.2 Implement before_create callback for automatic ID generation
  - [x] 2.3 Add find_by_opaque_id and find_by_opaque_id! class methods
  - [x] 2.4 Implement collision detection with configurable retry attempts
  - [x] 2.5 Add configuration options (column, length, alphabet, require_letter_start, purge_chars, max_retry)
  - [x] 2.6 Implement set_opaque_id private method with collision handling
  - [x] 2.7 Add generate_opaque_id private method using main module
  - [x] 2.8 Handle edge cases (already has ID, collision resolution failure)

- [x] 3.0 Build Rails Generator for Easy Setup

  - [x] 3.1 Create lib/generators/opaque_id directory structure
  - [x] 3.2 Implement InstallGenerator class with Rails::Generators::Base
  - [x] 3.3 Add table_name argument and column_name option handling
  - [x] 3.4 Create migration template (migration.rb.tt) with add_column and add_index
  - [x] 3.5 Implement create_migration_file method with error handling
  - [x] 3.6 Add model file modification to include OpaqueId::Model
  - [x] 3.7 Handle edge cases (missing model file, already included, different class names)
  - [x] 3.8 Add proper console output and error messages

- [x] 4.0 Update Gem Configuration and Dependencies

  - [x] 4.1 Update gemspec with proper summary and description
  - [x] 4.2 Add ActiveRecord and ActiveSupport dependencies (>= 8.0)
  - [x] 4.3 Add development dependencies (rake, sqlite3, rubocop, rails)
  - [x] 4.4 Update metadata (homepage, source_code_uri, changelog_uri)
  - [x] 4.5 Set required_ruby_version to >= 3.2
  - [x] 4.6 Configure file inclusion and exclusion patterns
  - [x] 4.7 Update Gemfile to match gemspec dependencies
  - [x] 4.8 Update Rakefile with test and rubocop tasks

- [x] 5.0 Create Comprehensive Test Suite

  - [x] 5.1 Create test/opaque_id directory structure
  - [x] 5.2 Implement test_opaque_id.rb with core module tests
  - [x] 5.3 Add tests for generate method (default length, custom length, alphabet validation)
  - [x] 5.4 Add tests for error conditions (invalid size, empty alphabet)
  - [x] 5.5 Add statistical uniformity tests for character distribution
  - [x] 5.6 Add performance benchmark tests for different alphabet sizes
  - [x] 5.7 Create test/opaque_id/model_test.rb for ActiveRecord concern
  - [x] 5.8 Test model integration (automatic generation, find methods, configuration)
  - [x] 5.9 Test collision detection and retry logic
  - [x] 5.10 Create test/opaque_id/generators/install_generator_test.rb
  - [x] 5.11 Test generator behavior (migration creation, model modification, edge cases)
  - [x] 5.12 Add test database setup and cleanup

- [x] 5.13 Configure RuboCop for code quality

  - [x] 5.13.1 Create .rubocop.yml configuration file
  - [x] 5.13.2 Set appropriate rules for gem development
  - [x] 5.13.3 Auto-correct all RuboCop offenses
  - [x] 5.13.4 Fix Rails 8.1 deprecation warning in test helper

- [ ] 6.0 Write Documentation and Examples
  - [x] 6.1 Update README.md with comprehensive feature list
  - [x] 6.2 Add installation instructions and gem usage
  - [x] 6.3 Create basic usage examples with code snippets
  - [x] 6.4 Add custom configuration examples
  - [x] 6.5 Document standalone generation usage
  - [x] 6.6 Add configuration options table with defaults
  - [x] 6.7 Document alphabet options (ALPHANUMERIC_ALPHABET, STANDARD_ALPHABET)
  - [x] 6.8 Add algorithm explanation and performance benchmarks
  - [x] 6.9 Create security considerations and use case examples
  - [x] 6.10 Add contributing guidelines and license information
  - [x] 6.11 Update CHANGELOG.md with version history
