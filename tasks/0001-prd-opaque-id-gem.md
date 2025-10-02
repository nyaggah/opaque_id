# Product Requirements Document: OpaqueId Ruby Gem

## Introduction/Overview

The OpaqueId gem is a Ruby library that generates cryptographically secure, collision-free opaque identifiers for ActiveRecord models. This gem replaces the existing `nanoid.rb` dependency by implementing the same functionality using Ruby's built-in `SecureRandom` methods, eliminating external dependencies while maintaining the same security and performance characteristics.

The primary problem this gem solves is preventing the exposure of incremental database IDs in public URLs and APIs, which can reveal business metrics, enable enumeration attacks, and expose internal system architecture. Instead, it provides opaque, non-sequential identifiers that are URL-friendly and cryptographically secure.

## Goals

1. **Replace nanoid.rb dependency** - Implement equivalent functionality using Ruby's built-in SecureRandom
2. **Maintain security standards** - Provide cryptographically secure ID generation with unbiased distribution
3. **Ensure performance** - Achieve 1M+ IDs/sec for 64-character alphabets, 180K+ IDs/sec for 36-character alphabets
4. **Simplify integration** - Provide seamless ActiveRecord integration with minimal configuration
5. **Enable wide adoption** - Create comprehensive documentation accessible to all Rails developers
6. **Ensure reliability** - Implement robust collision detection and retry logic
7. **Maintain compatibility** - Support Rails 8.0+ and Ruby 3.2+ environments

## User Stories

### Primary Users: Rails Developers

**As a Rails developer**, I want to generate opaque IDs for my models so that I can expose public identifiers without revealing database structure.

**As a Rails developer**, I want to easily integrate opaque ID generation into my existing models so that I don't have to manually implement ID generation logic.

**As a Rails developer**, I want to configure ID generation parameters (length, alphabet, column name) so that I can customize the behavior for different use cases.

**As a Rails developer**, I want to find records by their opaque ID so that I can build public-facing APIs and URLs.

**As a Rails developer**, I want the gem to handle collision detection automatically so that I don't have to worry about duplicate IDs.

**As a Rails developer**, I want comprehensive documentation and examples so that I can quickly understand and implement the gem in my project.

### Secondary Users: Security-Conscious Teams

**As a security-conscious developer**, I want cryptographically secure ID generation so that my public identifiers cannot be predicted or enumerated.

**As a security-conscious developer**, I want unbiased character distribution so that my IDs have maximum entropy and cannot be analyzed for patterns.

## Functional Requirements

### Core ID Generation

1. The system must generate cryptographically secure random IDs using Ruby's `SecureRandom`
2. The system must implement rejection sampling algorithm to ensure unbiased character distribution
3. The system must provide optimized fast path for 64-character alphabets using bitwise operations
4. The system must support custom alphabet configurations
5. The system must support custom ID length configurations
6. The system must provide two predefined alphabets: ALPHANUMERIC_ALPHABET (36 chars) and STANDARD_ALPHABET (64 chars)

### ActiveRecord Integration

7. The system must provide `OpaqueId::Model` concern for easy ActiveRecord integration
8. The system must automatically generate opaque IDs on model creation via `before_create` callback
9. The system must provide `find_by_opaque_id` and `find_by_opaque_id!` class methods
10. The system must support custom column names via `opaque_id_column` configuration
11. The system must implement collision detection with configurable retry attempts
12. The system must raise appropriate errors when collision resolution fails

### Rails Generator (Optional Convenience Tool)

13. The system must provide optional Rails generator `opaque_id:install` for creating migrations and updating models
14. The system must generate migration files that add opaque_id column with unique index
15. The system must automatically add `include OpaqueId::Model` to the corresponding model file
16. The system must support custom column names via generator options
17. The system must require explicit table name argument and show clear usage instructions when run without arguments
18. The system must work with any existing table (new or existing models)
19. The system must handle edge cases gracefully (missing model file, already included, different class names)

### Configuration Options

20. The system must support `opaque_id_column` configuration (default: `:opaque_id`)
21. The system must support `opaque_id_length` configuration (default: `18`)
22. The system must support `opaque_id_alphabet` configuration (default: `ALPHANUMERIC_ALPHABET`)
23. The system must support `opaque_id_require_letter_start` configuration (default: `true`)
24. The system must support `opaque_id_purge_chars` configuration (default: `nil`)
25. The system must support `opaque_id_max_retry` configuration (default: `1000`)

### Error Handling

26. The system must raise `OpaqueId::ConfigurationError` for invalid size or empty alphabet
27. The system must raise `OpaqueId::GenerationError` when collision resolution fails
28. The system must provide clear error messages for debugging

### Standalone Usage

29. The system must provide `OpaqueId.generate` method for standalone ID generation
30. The system must support all configuration options in standalone generation
31. The system must maintain the same security and performance characteristics in standalone mode

## Non-Goals (Out of Scope)

1. **Other ORM Support** - Will not support Mongoid, Sequel, or other ORMs in initial release
2. **Non-Rails Usage** - Will not provide standalone Ruby usage without ActiveRecord dependency
3. **Custom Algorithms** - Will not implement alternative ID generation algorithms beyond rejection sampling
4. **Database Migrations** - Will not provide automatic database migration for existing records
5. **ID Validation** - Will not provide built-in ID format validation (users can implement their own)
6. **Bulk Generation** - Will not provide optimized bulk ID generation methods
7. **ID Prefixes/Suffixes** - Will not support adding prefixes or suffixes to generated IDs
8. **Custom Random Sources** - Will not support custom random number generators beyond SecureRandom
9. **Interactive Generator Mode** - Will not provide interactive prompts for generator arguments
10. **Backward Compatibility** - Will not maintain compatibility with existing `public_id` implementations

## Design Considerations

### API Design

- Follow Rails conventions for ActiveRecord concerns and generators
- Use descriptive method names that clearly indicate functionality
- Provide both safe (`find_by_opaque_id`) and unsafe (`find_by_opaque_id!`) lookup methods
- Use class-level configuration options for easy customization
- Follow Devise-style generator pattern for seamless integration

### Performance Optimization

- Implement fast path for 64-character alphabets using bitwise operations (`byte & 63`)
- Use rejection sampling with optimal mask calculation for unbiased distribution
- Pre-allocate string capacity to avoid memory reallocation during generation
- Batch random byte generation to minimize SecureRandom calls

### Security Considerations

- Use only cryptographically secure random number generation
- Implement proper rejection sampling to avoid modulo bias
- Provide sufficient entropy through configurable alphabet sizes
- Ensure IDs cannot be predicted or enumerated

## Technical Considerations

### Dependencies

- **ActiveRecord**: >= 6.0 (targeting Rails 8.0+ compatibility)
- **ActiveSupport**: >= 6.0 (for concern functionality)
- **Ruby**: >= 3.2 (for modern Ruby features and performance)

### Testing Framework

- Use **Minitest** instead of RSpec for consistency with Rails conventions
- Implement comprehensive unit tests for all public methods
- Include statistical tests for character distribution uniformity
- Add performance benchmarks to ensure performance requirements are met
- Test edge cases including collision scenarios and error conditions

### File Structure

```
lib/
├── opaque_id.rb                 # Main module with generator
├── opaque_id/
│   ├── version.rb               # Version constant
│   └── model.rb                 # ActiveRecord concern
└── generators/
    └── opaque_id/
        ├── install_generator.rb  # Migration generator
        └── templates/
            └── migration.rb.tt   # Migration template
```

### Error Classes

- `OpaqueId::Error` - Base error class
- `OpaqueId::GenerationError` - ID generation failures
- `OpaqueId::ConfigurationError` - Invalid configuration

## Success Metrics

### Performance Metrics

- **Standard alphabet (64 chars)**: Achieve ~1.2M IDs/sec generation rate
- **Alphanumeric alphabet (36 chars)**: Achieve ~180K IDs/sec generation rate
- **Custom alphabet (20 chars)**: Achieve ~150K IDs/sec generation rate

### Quality Metrics

- **Test Coverage**: Achieve 95%+ code coverage
- **Documentation**: Provide comprehensive README with examples
- **Error Handling**: All error conditions properly tested and documented

### Adoption Metrics

- **Gem Downloads**: Target 1000+ downloads in first month
- **GitHub Stars**: Target 50+ stars within 6 months
- **Community Feedback**: Positive reception from Rails community

## Open Questions

1. **Version Strategy**: Should we follow semantic versioning strictly, or use a different versioning strategy for a utility gem?

2. **Backward Compatibility**: How should we handle potential breaking changes in future versions, especially regarding default configurations?

3. **Performance Testing**: Should we include automated performance regression testing in CI/CD, or rely on manual benchmarking?

4. **Documentation Hosting**: Should we create a dedicated documentation site, or rely on GitHub README and inline documentation?

5. **Community Contributions**: What level of community contribution should we expect, and how should we structure the project to encourage contributions?

6. **Integration Testing**: Should we test against multiple Rails versions in CI, or focus on the target Rails 8.0+ range?

7. **Security Auditing**: Should we implement any security auditing tools or processes for the random number generation?

8. **Migration Path**: How should we help users migrate from nanoid.rb to opaque_id, if at all?
