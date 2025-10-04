# OpaqueId Benchmarks

This document provides benchmark scripts that you can run to test OpaqueId's performance and uniqueness characteristics on your own system.

## Performance Benchmarks

### SecureRandom Comparison Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'
require 'securerandom'

puts "OpaqueId vs SecureRandom Comparison"
puts "=" * 50

# Test different Ruby standard library methods
methods = {
  'OpaqueId.generate' => -> { OpaqueId.generate },
  'SecureRandom.urlsafe_base64' => -> { SecureRandom.urlsafe_base64 },
  'SecureRandom.urlsafe_base64(16)' => -> { SecureRandom.urlsafe_base64(16) },
  'SecureRandom.hex(9)' => -> { SecureRandom.hex(9) },
  'SecureRandom.alphanumeric(18)' => -> { SecureRandom.alphanumeric(18) }
}

count = 10000

puts "Performance comparison (#{count} IDs each):"
puts "-" * 50

methods.each do |name, method|
  start_time = Time.now
  ids = count.times.map { method.call }
  end_time = Time.now
  duration = end_time - start_time
  rate = (count / duration).round(0)

  # Check uniqueness
  unique_count = ids.uniq.length
  collisions = count - unique_count

  # Check characteristics
  sample_id = ids.first
  length = sample_id.length
  has_uppercase = sample_id.match?(/[A-Z]/)
  has_lowercase = sample_id.match?(/[a-z]/)
  has_numbers = sample_id.match?(/[0-9]/)
  has_special = sample_id.match?(/[^A-Za-z0-9]/)

  puts "#{name.ljust(30)}: #{duration.round(4)}s (#{rate} IDs/sec)"
  puts "  Length: #{length}, Collisions: #{collisions}"
  puts "  Sample: '#{sample_id}'"
  puts "  Chars: #{has_uppercase ? 'A-Z' : ''}#{has_lowercase ? 'a-z' : ''}#{has_numbers ? '0-9' : ''}#{has_special ? 'special' : ''}"
  puts
end

puts "Comparison completed."
```

### Basic Performance Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "OpaqueId Performance Benchmark"
puts "=" * 40

# Test different batch sizes
[100, 1000, 10000, 100000].each do |count|
  start_time = Time.now
  count.times { OpaqueId.generate }
  end_time = Time.now
  duration = end_time - start_time
  rate = (count / duration).round(0)

  puts "#{count.to_s.rjust(6)} IDs: #{duration.round(4)}s (#{rate} IDs/sec)"
end

puts "\nPerformance test completed."
```

### Alphabet Performance Comparison

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "Alphabet Performance Comparison"
puts "=" * 40

alphabets = {
  'SLUG_LIKE_ALPHABET' => OpaqueId::SLUG_LIKE_ALPHABET,
  'ALPHANUMERIC_ALPHABET' => OpaqueId::ALPHANUMERIC_ALPHABET,
  'STANDARD_ALPHABET' => OpaqueId::STANDARD_ALPHABET
}

count = 10000

alphabets.each do |name, alphabet|
  start_time = Time.now
  count.times { OpaqueId.generate(alphabet: alphabet) }
  end_time = Time.now
  duration = end_time - start_time
  rate = (count / duration).round(0)

  puts "#{name.ljust(20)}: #{duration.round(4)}s (#{rate} IDs/sec)"
end

puts "\nAlphabet comparison completed."
```

### Size Performance Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "Size Performance Test"
puts "=" * 40

sizes = [8, 12, 18, 24, 32, 48, 64]
count = 10000

sizes.each do |size|
  start_time = Time.now
  count.times { OpaqueId.generate(size: size) }
  end_time = Time.now
  duration = end_time - start_time
  rate = (count / duration).round(0)

  puts "Size #{size.to_s.rjust(2)}: #{duration.round(4)}s (#{rate} IDs/sec)"
end

puts "\nSize performance test completed."
```

## Uniqueness Tests

### Collision Probability Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "Collision Probability Test"
puts "=" * 40

# Test different sample sizes
[1000, 10000, 100000].each do |count|
  puts "\nTesting #{count} IDs..."

  start_time = Time.now
  ids = count.times.map { OpaqueId.generate }
  end_time = Time.now

  unique_ids = ids.uniq
  collisions = count - unique_ids.length
  collision_rate = (collisions.to_f / count * 100).round(6)

  puts "  Generated: #{count} IDs in #{(end_time - start_time).round(4)}s"
  puts "  Unique: #{unique_ids.length} IDs"
  puts "  Collisions: #{collisions} (#{collision_rate}%)"
  puts "  Uniqueness: #{collision_rate == 0 ? '✅ Perfect' : '⚠️  Collisions detected'}"
end

puts "\nCollision test completed."
```

### Birthday Paradox Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "Birthday Paradox Test"
puts "=" * 40

# Test the birthday paradox with different sample sizes
# For 18-character slug-like alphabet (36 chars), we have 36^18 possible combinations
# This is approximately 10^28, so collisions should be extremely rare

sample_sizes = [1000, 10000, 50000, 100000]

sample_sizes.each do |count|
  puts "\nTesting #{count} IDs for birthday paradox..."

  start_time = Time.now
  ids = count.times.map { OpaqueId.generate }
  end_time = Time.now

  unique_ids = ids.uniq
  collisions = count - unique_ids.length

  # Calculate theoretical collision probability
  # For 18-char slug-like alphabet: 36^18 ≈ 10^28 possible combinations
  alphabet_size = 36
  id_length = 18
  total_possibilities = alphabet_size ** id_length

  # Approximate birthday paradox probability
  # P(collision) ≈ 1 - e^(-n(n-1)/(2*N)) where n=sample_size, N=total_possibilities
  n = count
  N = total_possibilities
  theoretical_prob = 1 - Math.exp(-(n * (n - 1)) / (2.0 * N))

  puts "  Sample size: #{count}"
  puts "  Total possibilities: #{total_possibilities.to_s.reverse.gsub(/(\d{3})(?=.)/, '\1,').reverse}"
  puts "  Theoretical collision probability: #{theoretical_prob.round(20)}"
  puts "  Actual collisions: #{collisions}"
  puts "  Result: #{collisions == 0 ? '✅ No collisions (as expected)' : '⚠️  Collisions detected'}"
end

puts "\nBirthday paradox test completed."
```

### Alphabet Distribution Test

```ruby
#!/usr/bin/env ruby

require 'opaque_id'

puts "Alphabet Distribution Test"
puts "=" * 40

# Test that all characters in the alphabet are used roughly equally
alphabet = OpaqueId::SLUG_LIKE_ALPHABET
count = 100000

puts "Testing distribution for #{alphabet.length}-character alphabet..."
puts "Sample size: #{count} IDs"

start_time = Time.now
ids = count.times.map { OpaqueId.generate }
end_time = Time.now

# Count character frequency
char_counts = Hash.new(0)
ids.each do |id|
  id.each_char { |char| char_counts[char] += 1 }
end

total_chars = ids.join.length
expected_per_char = total_chars.to_f / alphabet.length

puts "\nCharacter distribution:"
puts "Character | Count | Expected | Deviation"
puts "-" * 45

alphabet.each_char do |char|
  count = char_counts[char]
  deviation = ((count - expected_per_char) / expected_per_char * 100).round(2)
  puts "#{char.ljust(8)} | #{count.to_s.rjust(5)} | #{expected_per_char.round(1).to_s.rjust(8)} | #{deviation.to_s.rjust(6)}%"
end

# Calculate chi-square test for uniform distribution
chi_square = alphabet.each_char.sum do |char|
  observed = char_counts[char]
  expected = expected_per_char
  ((observed - expected) ** 2) / expected
end

puts "\nChi-square statistic: #{chi_square.round(4)}"
puts "Distribution: #{chi_square < 30 ? '✅ Appears uniform' : '⚠️  May not be uniform'}"

puts "\nDistribution test completed."
```

## Running the Benchmarks

### Quick Performance Test

```bash
# Run basic performance test
ruby -e "
require 'opaque_id'
puts 'OpaqueId Performance Test'
puts '=' * 30
[100, 1000, 10000].each do |count|
  start = Time.now
  count.times { OpaqueId.generate }
  duration = Time.now - start
  rate = (count / duration).round(0)
  puts \"#{count.to_s.rjust(5)} IDs: #{duration.round(4)}s (#{rate} IDs/sec)\"
end
"
```

### Quick Uniqueness Test

```bash
# Run basic uniqueness test
ruby -e "
require 'opaque_id'
puts 'OpaqueId Uniqueness Test'
puts '=' * 30
count = 10000
ids = count.times.map { OpaqueId.generate }
unique = ids.uniq
collisions = count - unique.length
puts \"Generated: #{count} IDs\"
puts \"Unique: #{unique.length} IDs\"
puts \"Collisions: #{collisions}\"
puts \"Result: #{collisions == 0 ? 'Perfect uniqueness' : 'Collisions detected'}\"
"
```

## Expected Results

### Performance Expectations

On a modern system, you should expect:

- **100 IDs**: < 0.001s (100,000+ IDs/sec)
- **1,000 IDs**: < 0.01s (100,000+ IDs/sec)
- **10,000 IDs**: < 0.1s (100,000+ IDs/sec)
- **100,000 IDs**: < 1s (100,000+ IDs/sec)

### Uniqueness Expectations

- **1,000 IDs**: 0 collisions (100% unique)
- **10,000 IDs**: 0 collisions (100% unique)
- **100,000 IDs**: 0 collisions (100% unique)
- **1,000,000 IDs**: 0 collisions (100% unique)

The theoretical collision probability for 1 million IDs is approximately 10^-16, making collisions virtually impossible in practice.

## System Requirements

These benchmarks require:

- Ruby 2.7+ (for optimal performance)
- OpaqueId gem installed
- Sufficient memory for large sample sizes

For the largest tests (100,000+ IDs), ensure you have at least 100MB of available memory.

## Why Not Just Use SecureRandom?

Ruby's `SecureRandom` already provides secure random generation. Here's how OpaqueId compares:

### SecureRandom.urlsafe_base64 vs OpaqueId

| Feature                      | SecureRandom.urlsafe_base64     | OpaqueId.generate            |
| ---------------------------- | ------------------------------- | ---------------------------- |
| **Length**                   | 22 characters (fixed)           | 18 characters (configurable) |
| **Alphabet**                 | A-Z, a-z, 0-9, -, \_ (64 chars) | 0-9, a-z (36 chars)          |
| **URL Safety**               | ✅ Yes                          | ✅ Yes                       |
| **Double-click selectable**  | ❌ No (contains special chars)  | ✅ Yes (no special chars)    |
| **Configurable length**      | ❌ No                           | ✅ Yes                       |
| **Configurable alphabet**    | ❌ No                           | ✅ Yes                       |
| **ActiveRecord integration** | ❌ Manual                       | ✅ Built-in                  |
| **Rails generator**          | ❌ No                           | ✅ Yes                       |

### When to Use Each

**Use SecureRandom.urlsafe_base64 when:**

- You need maximum entropy (22 chars vs 18)
- You don't mind special characters (-, \_)
- You don't need double-click selection
- You're building a simple solution

**Use OpaqueId when:**

- You want slug-like IDs (no special characters)
- You need double-click selectable IDs
- You want configurable length and alphabet
- You're using ActiveRecord models
- You want consistent ID length (default: 18 characters)

### Performance Comparison

Run the [SecureRandom Comparison Test](#securerandom-comparison-test) to see how OpaqueId compares to various SecureRandom methods on your system.

### Migration from nanoid.rb

The nanoid.rb gem is [considered obsolete](https://github.com/radeno/nanoid.rb/issues/67) for Ruby 2.7+ because SecureRandom provides similar functionality. OpaqueId provides an alternative with different defaults and Rails integration.
