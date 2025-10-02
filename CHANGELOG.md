# Changelog

All notable changes to the OpaqueId gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2](https://github.com/nyaggah/opaque_id/compare/v1.0.1...v1.0.2) (2025-10-02)


### Bug Fixes

* remove unsupported Release Please configuration parameters ([e3b0d2a](https://github.com/nyaggah/opaque_id/commit/e3b0d2ac96b905316a78992004fae83423991632))

## [1.0.1](https://github.com/nyaggah/opaque_id/compare/v1.0.0...v1.0.1) (2025-10-02)


### Bug Fixes

* improve publish workflow trigger reliability ([9c6e240](https://github.com/nyaggah/opaque_id/commit/9c6e2402474d8ecf8a3f754a9f2ca149a63bf1d1))
* improve statistical test reliability for CI ([c9b0d52](https://github.com/nyaggah/opaque_id/commit/c9b0d52fb4e9559aad489fcf58bdff1917d613a6))

## 1.0.0 (2025-10-02)


### Features

* initial release of OpaqueId gem v0.1.0 ([3a90274](https://github.com/nyaggah/opaque_id/commit/3a9027403552f8160e3aaf413d1e99ce8c63bbe4))


### Bug Fixes

* resolve dependency version conflicts and improve test robustness ([af43e13](https://github.com/nyaggah/opaque_id/commit/af43e13393a452f11ce32bafb26a267d1460736c))

## [Unreleased]

### Added

- Nothing yet

### Changed

- Nothing yet

### Deprecated

- Nothing yet

### Removed

- Nothing yet

### Fixed

- Nothing yet

### Security

- Nothing yet

## [0.1.0] - 2025-01-XX

### Added

- **Core ID Generation**: Secure, collision-free ID generation using Ruby's `SecureRandom`
- **Fast Path Algorithm**: Optimized bitwise operations for 64-character alphabets
- **Unbiased Path Algorithm**: Rejection sampling for other alphabet sizes to eliminate modulo bias
- **ActiveRecord Integration**: `OpaqueId::Model` concern for automatic ID generation
- **Rails Generator**: `opaque_id:install` generator for easy setup
- **Built-in Alphabets**: `ALPHANUMERIC_ALPHABET` (62 chars) and `STANDARD_ALPHABET` (64 chars)
- **Configuration Options**: Customizable ID length, alphabet, letter start requirement, character purging
- **Finder Methods**: `find_by_opaque_id` and `find_by_opaque_id!` for model lookups
- **Collision Handling**: Automatic retry with configurable max attempts
- **Error Classes**: `OpaqueId::Error`, `OpaqueId::ConfigurationError`, `OpaqueId::GenerationError`
- **Comprehensive Test Suite**: Minitest-based tests covering core functionality, ActiveRecord integration, and generators
- **Performance Benchmarks**: Statistical uniformity tests and performance measurements
- **Security Features**: Cryptographically secure random generation, unbiased distribution
- **Documentation**: Complete README with usage examples, security considerations, and use cases

### Technical Details

- **Ruby Compatibility**: Requires Ruby 3.2.0 or higher
- **Rails Compatibility**: Requires Rails 8.0 or higher
- **Dependencies**: ActiveRecord, ActiveSupport
- **Performance**: ~2.5M IDs/sec for 64-character alphabets, ~1.2M IDs/sec for other alphabets
- **Collision Resistance**: 2^126 possible combinations for 21-character STANDARD_ALPHABET IDs
- **Memory Usage**: ~21 bytes per ID, consistent across all algorithms

### Security

- Uses Ruby's `SecureRandom` for cryptographically secure entropy
- Implements rejection sampling to eliminate modulo bias
- Provides non-sequential, unpredictable IDs
- Includes comprehensive security guidelines and best practices
- Supports configurable ID lengths for different security requirements

### Documentation

- Complete installation and setup instructions
- Detailed usage examples for standalone and ActiveRecord integration
- Comprehensive configuration options documentation
- Security considerations and threat model analysis
- Real-world use case examples (e-commerce, APIs, CMS, etc.)
- Performance benchmarks and optimization tips
- Development and contribution guidelines
- MIT License with full legal details

### Testing

- **Core Module Tests**: ID generation, error handling, edge cases
- **ActiveRecord Integration Tests**: Model callbacks, finder methods, configuration
- **Generator Tests**: Migration generation, model modification
- **Performance Tests**: Statistical uniformity validation
- **Error Handling Tests**: Invalid inputs, collision scenarios
- **RuboCop Integration**: Code quality and style enforcement

### Generator Features

- **Migration Generation**: Creates `opaque_id` column with unique index
- **Model Modification**: Automatically adds `include OpaqueId::Model`
- **Customizable Options**: Column name, alphabet, length configuration
- **Error Handling**: Graceful handling of missing models or invalid arguments
- **Console Output**: Color-coded success and error messages

### Breaking Changes

- None (initial release)

### Migration Notes

- This is the initial release of OpaqueId
- No migration from previous versions required
- Compatible with Rails 8.0+ applications
- Requires Ruby 3.2.0 or higher
