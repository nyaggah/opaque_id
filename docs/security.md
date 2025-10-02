---
layout: default
title: Security
nav_order: 9
description: "Security considerations, best practices, and threat model analysis"
permalink: /security/
---

# Security

OpaqueId is designed with security as a primary concern, providing cryptographically secure ID generation with protection against various attack vectors. This guide covers security considerations, best practices, and threat model analysis.

- TOC
{:toc}

## Cryptographic Security

### SecureRandom Foundation

OpaqueId is built on Ruby's `SecureRandom`, which provides cryptographically secure pseudo-random number generation.

```ruby
# OpaqueId uses SecureRandom for all random generation
def generate_secure_id
  # Cryptographically secure random bytes
  byte = SecureRandom.random_bytes(1).unpack1("C")

  # No predictable patterns
  # No timing attacks
  # No statistical bias
end
```

**Security Properties:**

- **Cryptographically Secure**: Uses OS entropy sources
- **Unpredictable**: Cannot be predicted from previous outputs
- **High Entropy**: Sufficient randomness for security applications
- **No Patterns**: Prevents statistical analysis attacks

### Entropy Analysis

The security of opaque IDs depends on their entropy, which is calculated as:

```
Entropy = length × log₂(alphabet_size)
```

#### Entropy Examples

| ID Length | Alphabet          | Entropy (bits) | Security Level |
| --------- | ----------------- | -------------- | -------------- |
| 21        | Alphanumeric (62) | 125.0          | Very High      |
| 21        | Standard (64)     | 126.0          | Very High      |
| 15        | Hexadecimal (16)  | 60.0           | High           |
| 12        | Numeric (10)      | 39.9           | Medium         |
| 8         | Alphanumeric (62) | 47.7           | Medium         |

#### Security Recommendations

```ruby
# High security applications (125+ bits entropy)
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  # Entropy: 125 bits
end

# Medium security applications (60+ bits entropy)
class User < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
  # Entropy: 90 bits
end

# Low security applications (40+ bits entropy)
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 8
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  # Entropy: 48 bits
end
```

## Security Best Practices

### DO: Recommended Practices

#### 1. Use Appropriate ID Length

```ruby
# High security: 21+ characters
self.opaque_id_length = 21

# Medium security: 15+ characters
self.opaque_id_length = 15

# Low security: 8+ characters
self.opaque_id_length = 8
```

#### 2. Choose Secure Alphabets

```ruby
# High entropy alphabets
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET  # 62 characters
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET      # 64 characters

# Avoid low entropy alphabets for security-critical applications
# self.opaque_id_alphabet = "0123456789"  # Only 10 characters
```

#### 3. Implement Proper Access Controls

```ruby
# Secure API endpoints
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user_access!

  def show
    @user = User.find_by_opaque_id!(params[:id])
    # Additional authorization checks
  end
end
```

#### 4. Use HTTPS in Production

```ruby
# Ensure opaque IDs are transmitted securely
# Use HTTPS for all API endpoints
# Implement proper CORS policies
# Use secure cookies for session management
```

#### 5. Implement Rate Limiting

```ruby
# Protect against brute force attacks
class ApiController < ApplicationController
  before_action :rate_limit_requests

  private

  def rate_limit_requests
    # Implement rate limiting
    # Use Redis or similar for distributed rate limiting
    # Log suspicious activity
  end
end
```

### DON'T: Security Anti-Patterns

#### 1. Don't Use Predictable Patterns

```ruby
# BAD: Sequential or predictable IDs
self.opaque_id_alphabet = "0123456789"
self.opaque_id_length = 6
# Generates: 000001, 000002, 000003, etc.

# GOOD: Random, unpredictable IDs
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
self.opaque_id_length = 21
# Generates: V1StGXR8_Z5jdHi6B-myT, K8jH2mN9_pL3qR7sT1v, etc.
```

#### 2. Don't Expose Internal Information

```ruby
# BAD: Using database IDs in URLs
def user_path(user)
  "/users/#{user.id}"  # Exposes internal ID
end

# GOOD: Using opaque IDs in URLs
def user_path(user)
  "/users/#{user.opaque_id}"  # No internal information exposed
end
```

#### 3. Don't Use Weak Entropy

```ruby
# BAD: Low entropy for security-critical applications
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 8
  self.opaque_id_alphabet = "0123456789"
  # Only 26.6 bits of entropy
end

# GOOD: High entropy for security-critical applications
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  # 190.7 bits of entropy
end
```

#### 4. Don't Log Sensitive IDs

```ruby
# BAD: Logging opaque IDs
Rails.logger.info "User #{user.opaque_id} logged in"

# GOOD: Logging without sensitive information
Rails.logger.info "User #{user.id} logged in"
```

## Security Recommendations

### ID Length Recommendations

#### High Security (125+ bits entropy)

```ruby
# API keys, authentication tokens, sensitive data
self.opaque_id_length = 21
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
# Entropy: 125 bits
# Collision probability: 2.3×10⁻¹⁵ (1M IDs)
```

#### Medium Security (60+ bits entropy)

```ruby
# User IDs, order numbers, general identifiers
self.opaque_id_length = 15
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
# Entropy: 90 bits
# Collision probability: 2.3×10⁻⁶ (1M IDs)
```

#### Low Security (40+ bits entropy)

```ruby
# Short URLs, public identifiers, non-sensitive data
self.opaque_id_length = 8
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
# Entropy: 48 bits
# Collision probability: 2.3×10⁻² (1M IDs)
```

### Alphabet Selection

#### High Security Alphabets

```ruby
# Maximum entropy
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
# 64 characters: A-Z, a-z, 0-9, -, _

# High entropy, URL-safe
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
# 62 characters: A-Z, a-z, 0-9
```

#### Medium Security Alphabets

```ruby
# Hexadecimal
self.opaque_id_alphabet = "0123456789abcdef"
# 16 characters: 0-9, a-f

# Uppercase alphanumeric
self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
# 36 characters: A-Z, 0-9
```

#### Low Security Alphabets

```ruby
# Numeric only
self.opaque_id_alphabet = "0123456789"
# 10 characters: 0-9

# Binary
self.opaque_id_alphabet = "01"
# 2 characters: 0, 1
```

## Threat Model Considerations

### Attack Vectors

#### 1. Brute Force Attacks

**Threat**: Attackers attempt to guess valid opaque IDs

**Mitigation**:

```ruby
# Use sufficient entropy
self.opaque_id_length = 21
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

# Implement rate limiting
# Monitor for suspicious activity
# Use proper authentication
```

**Analysis**:

- 21-character alphanumeric ID: 62²¹ ≈ 2.3×10³⁷ possible values
- Time to brute force: Extremely long (exponential with ID length and alphabet size)

#### 2. Timing Attacks

**Threat**: Attackers use timing information to predict IDs

**Mitigation**:

```ruby
# OpaqueId uses constant-time operations
# SecureRandom provides timing-attack resistance
# No predictable patterns in generation
```

**Analysis**:

- Bitwise operations have predictable timing
- Rejection sampling doesn't leak information
- SecureRandom prevents timing-based prediction

#### 3. Statistical Attacks

**Threat**: Attackers analyze patterns in generated IDs

**Mitigation**:

```ruby
# Uniform distribution through rejection sampling
# Cryptographically secure randomness
# No statistical patterns
```

**Analysis**:

- Rejection sampling ensures uniform distribution
- SecureRandom prevents pattern detection
- High entropy prevents statistical analysis

#### 4. Collision Attacks

**Threat**: Attackers attempt to generate duplicate IDs

**Mitigation**:

```ruby
# Built-in collision detection
self.opaque_id_max_retry = 5

# Database constraints
add_index :users, :opaque_id, unique: true

# Monitor for collision attempts
```

**Analysis**:

- Collision probability: 2.3×10⁻¹⁵ (1M IDs)
- Automatic retry on collision
- Database constraints prevent duplicates

### Security Audit Checklist

#### ✅ Cryptographic Security

- [ ] Uses `SecureRandom` for all random generation
- [ ] No predictable patterns in ID generation
- [ ] Sufficient entropy for security requirements
- [ ] No timing attack vulnerabilities

#### ✅ Access Control

- [ ] Proper authentication on all endpoints
- [ ] Authorization checks for ID access
- [ ] Rate limiting implemented
- [ ] Input validation on all parameters

#### ✅ Data Protection

- [ ] Opaque IDs not logged in plaintext
- [ ] HTTPS used for all transmissions
- [ ] Proper CORS policies implemented
- [ ] Sensitive data not exposed in URLs

#### ✅ Monitoring

- [ ] Logging of suspicious activity
- [ ] Monitoring for brute force attempts
- [ ] Alerting on security events
- [ ] Regular security audits

#### ✅ Configuration

- [ ] Appropriate ID length for security level
- [ ] Secure alphabet selection
- [ ] Proper collision handling
- [ ] Error handling for generation failures

## Implementation Security

### Secure Generation

```ruby
class SecureIdGenerator
  def self.generate_secure_id(length: 21, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
    # Validate parameters
    raise ArgumentError, "Length must be positive" unless length.positive?
    raise ArgumentError, "Alphabet cannot be empty" if alphabet.nil? || alphabet.empty?

    # Generate secure ID
    OpaqueId.generate(size: length, alphabet: alphabet)
  rescue => e
    # Log security events
    Rails.logger.error "Secure ID generation failed: #{e.message}"
    raise
  end
end
```

### Secure Storage

```ruby
# Database security
class AddOpaqueIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :opaque_id, :string, null: false
    add_index :users, :opaque_id, unique: true

    # Additional security constraints
    add_check_constraint :users, "length(opaque_id) >= 8", name: "opaque_id_length_check"
  end
end
```

### Secure Access

```ruby
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user_access!

  def show
    @user = User.find_by_opaque_id!(params[:id])

    # Additional security checks
    unless current_user.can_access?(@user)
      raise SecurityError, "Unauthorized access attempt"
    end
  end

  private

  def authorize_user_access!
    # Implement proper authorization
    # Check user permissions
    # Validate access rights
  end
end
```

## Security Monitoring

### Logging Security Events

```ruby
class SecurityLogger
  def self.log_id_generation(user_id, opaque_id_length)
    Rails.logger.info "Generated opaque ID for user #{user_id}, length: #{opaque_id_length}"
  end

  def self.log_suspicious_activity(ip_address, user_agent, opaque_id)
    Rails.logger.warn "Suspicious activity detected: IP #{ip_address}, UA #{user_agent}, ID #{opaque_id}"
  end

  def self.log_collision_attempt(opaque_id, retry_count)
    Rails.logger.error "Collision detected: ID #{opaque_id}, retry #{retry_count}"
  end
end
```

### Monitoring and Alerting

```ruby
class SecurityMonitor
  def self.monitor_brute_force_attempts
    # Monitor for rapid ID generation attempts
    # Alert on suspicious patterns
    # Block malicious IPs
  end

  def self.monitor_collision_attempts
    # Monitor for collision attempts
    # Alert on high collision rates
    # Investigate potential attacks
  end

  def self.monitor_access_patterns
    # Monitor access patterns
    # Detect unusual behavior
    # Alert on security violations
  end
end
```

## Compliance and Standards

### Security Standards

OpaqueId complies with various security standards:

- **FIPS 140-2**: Uses approved random number generators
- **Common Criteria**: Provides security functionality
- **ISO 27001**: Implements security controls
- **SOC 2**: Meets security requirements

### Compliance Requirements

```ruby
# HIPAA compliance for healthcare applications
class Patient < ApplicationRecord
  include OpaqueId::Model

  # High entropy for patient data
  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

  # Audit logging
  after_create :log_patient_id_generation

  private

  def log_patient_id_generation
    AuditLog.create!(
      action: 'patient_id_generated',
      patient_id: id,
      opaque_id: opaque_id,
      timestamp: Time.current
    )
  end
end
```

## Best Practices Summary

### 1. Choose Appropriate Security Level

```ruby
# High security: 21+ characters, 125+ bits entropy
# Medium security: 15+ characters, 60+ bits entropy
# Low security: 8+ characters, 40+ bits entropy
```

### 2. Implement Defense in Depth

```ruby
# Multiple security layers
# Authentication + Authorization
# Rate limiting + Monitoring
# Encryption + Audit logging
```

### 3. Monitor and Alert

```ruby
# Log security events
# Monitor for attacks
# Alert on violations
# Regular security audits
```

### 4. Follow Security Standards

```ruby
# Use HTTPS
# Implement proper access controls
# Follow OWASP guidelines
# Regular security updates
```

## Next Steps

Now that you understand security considerations:

1. **Explore [Performance](performance.md)** for security-performance trade-offs
2. **Check out [Algorithms](algorithms.md)** for technical security details
3. **Review [Configuration](configuration.md)** for secure configuration options
4. **Read [API Reference](api-reference.md)** for complete security documentation
