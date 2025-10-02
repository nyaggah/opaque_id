---
layout: default
title: Performance
nav_order: 8
description: "Performance benchmarks, optimization tips, and scalability considerations"
permalink: /performance/
---

# Performance

OpaqueId is designed for high performance with optimized algorithms and efficient memory usage. This guide covers benchmarks, optimization strategies, and scalability considerations.

## Performance Characteristics

### Generation Speed

OpaqueId is designed for high performance with optimized algorithms for different alphabet sizes and ID lengths.

#### Algorithm Performance

- **Fast Path (64-character alphabets)**: Uses bitwise operations for maximum speed with no rejection sampling overhead
- **Unbiased Path (Other alphabets)**: Uses rejection sampling for unbiased distribution with slight performance overhead
- **Performance scales linearly** with ID length and batch size

#### ID Length Impact

- **Shorter IDs**: Faster generation due to less computation
- **Longer IDs**: More secure but require more computation
- **Memory usage**: Scales linearly with ID length and batch size

### Memory Usage

OpaqueId is memory-efficient with predictable memory consumption patterns.

#### Memory Characteristics

- **Efficient memory usage**: Minimal memory overhead per ID generation
- **Linear scaling**: Memory usage scales predictably with ID length and batch size
- **Garbage collection**: Minimal impact on garbage collection due to efficient string handling

#### Memory Optimization

```ruby
# Efficient batch generation
def generate_batch_efficient(count, size, alphabet)
  # Pre-allocate result array
  results = Array.new(count)

  # Generate IDs in batches to control memory
  batch_size = 10000
  count.times_slice(batch_size) do |batch|
    batch.each_with_index do |_, i|
      results[i] = OpaqueId.generate(size: size, alphabet: alphabet)
    end

    # Force garbage collection for large batches
    GC.start if count > 100000
  end

  results
end
```

### Collision Probability

OpaqueId provides extremely low collision probabilities for practical use cases.

#### Collision Analysis

The collision probability depends on:

- **ID length**: Longer IDs have exponentially lower collision probability
- **Alphabet size**: Larger alphabets provide more entropy per character
- **Total IDs generated**: Collision probability increases with the square of the number of IDs

#### Mathematical Foundation

- **21-character alphanumeric (62 chars)**: ~125 bits of entropy
- **21-character standard (64 chars)**: ~126 bits of entropy
- **Collision probability**: Follows the birthday paradox formula
- **Practical safety**: Collisions are extremely unlikely for typical use cases

## Performance Characteristics

### Algorithm Performance

#### Fast Path (64-character alphabets)

```ruby
# Optimized for 64-character alphabets
# Uses bitwise operations for maximum speed
# No rejection sampling overhead
# Linear time complexity: O(n)
```

#### Unbiased Path (Other alphabets)

```ruby
# Uses rejection sampling for unbiased distribution
# Slight performance overhead for uniformity
# Linear time complexity: O(n × rejection_rate)
```

### Scalability Analysis

#### Linear Scaling

- **ID length**: Performance scales linearly with ID length
- **Batch size**: Performance remains consistent across different batch sizes
- **Memory usage**: Scales predictably with both ID length and batch size

## Real-World Performance

### ActiveRecord Integration

OpaqueId adds minimal overhead to ActiveRecord operations:

- **Automatic generation**: IDs are generated during model creation
- **Minimal performance impact**: Generation overhead is typically negligible
- **Memory efficient**: No significant memory overhead per record

### Batch Operations

```ruby
# Bulk insert with pre-generated IDs
ids = 100000.times.map { OpaqueId.generate }

users_data = ids.map.with_index do |id, index|
  { opaque_id: id, name: "User #{index + 1}" }
end

User.insert_all(users_data)
# Much faster than individual creates
```

### API Performance

- **Database indexing**: Ensure proper indexes on opaque_id columns for optimal lookup performance
- **Query performance**: Lookups by opaque_id should be fast with proper indexing
- **Response times**: Performance depends on database configuration and indexing

## Optimization Tips

### 1. Choose Optimal Alphabet Size

```ruby
# For maximum performance, use 64-character alphabets
class User < ApplicationRecord
  include OpaqueId::Model

  # Fastest generation
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# For specific requirements, consider performance impact
class Order < ApplicationRecord
  include OpaqueId::Model

  # Numeric-only (slower but meets requirements)
  self.opaque_id_alphabet = "0123456789"
end
```

### 2. Optimize ID Length

```ruby
# Shorter IDs for better performance
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  # 8 characters: faster generation
  self.opaque_id_length = 8
end

# Longer IDs for better security
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # 32 characters: higher security
  self.opaque_id_length = 32
end
```

### 3. Batch Generation

```ruby
# Generate IDs in batches for better performance
def generate_batch_ids(count, size: 21, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
  # Pre-allocate array
  results = Array.new(count)

  # Generate all IDs
  count.times do |i|
    results[i] = OpaqueId.generate(size: size, alphabet: alphabet)
  end

  results
end

# Usage
ids = generate_batch_ids(10000)
# Much faster than individual calls
```

### 4. Memory Management

```ruby
# For large-scale generation, manage memory carefully
def generate_large_batch(count, size: 21, alphabet: OpaqueId::ALPHANUMERIC_ALPHABET)
  results = []
  batch_size = 10000

  (count / batch_size).times do
    batch = batch_size.times.map { OpaqueId.generate(size: size, alphabet: alphabet) }
    results.concat(batch)

    # Force garbage collection for large batches
    GC.start if count > 100000
  end

  results
end
```

### 5. Database Optimization

```ruby
# Ensure proper database indexing
class AddOpaqueIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :opaque_id, :string
    add_index :users, :opaque_id, unique: true
  end
end

# Use database-specific optimizations
# PostgreSQL: Partial indexes for specific use cases
# MySQL: Use appropriate storage engine (InnoDB)
# SQLite: Consider WAL mode for better concurrency
```

## Performance Testing

### Benchmark Scripts

```ruby
# Basic performance benchmark
require 'benchmark'

def benchmark_generation(count = 1000000)
  puts "Generating #{count} opaque IDs..."

  time = Benchmark.measure do
    count.times { OpaqueId.generate }
  end

  puts "Time: #{time.real.round(2)} seconds"
  puts "Rate: #{(count / time.real).round(0)} IDs/second"
  puts "Memory: #{`ps -o rss= -p #{Process.pid}`.to_i / 1024}MB"
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
  puts "Objects allocated: #{report.total_allocated}"
  puts "Objects retained: #{report.total_retained}"
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
  puts "Per thread: #{(ids_per_thread / duration).round(0)} IDs/second"

  pool.shutdown
  pool.wait_for_termination
end

# Run load test
load_test(10, 100000)
```

## Performance Comparison

### vs. Other ID Generation Methods

OpaqueId compares favorably to other ID generation methods:

- **SecureRandom.hex**: OpaqueId provides more customization and collision handling
- **SecureRandom.uuid**: OpaqueId offers configurable length and alphabet
- **NanoID (gem)**: OpaqueId uses native Ruby methods without external dependencies
- **Database auto-increment**: OpaqueId provides security and URL-safety at minimal performance cost

### vs. Database-Generated IDs

```ruby
# Database auto-increment vs OpaqueId

# Database auto-increment
# Pros: Fast, sequential, small storage
# Cons: Predictable, not URL-safe, reveals count

# OpaqueId
# Pros: Unpredictable, URL-safe, configurable
# Cons: Slightly slower, larger storage
```

## Production Considerations

### 1. Monitoring

```ruby
# Add performance monitoring
class User < ApplicationRecord
  include OpaqueId::Model

  private

  def set_opaque_id
    start_time = Time.now
    self.opaque_id = generate_opaque_id
    duration = Time.now - start_time

    # Log slow generation
    Rails.logger.warn "Slow opaque_id generation: #{duration}ms" if duration > 0.001
  end
end
```

### 2. Caching

```ruby
# Cache generated IDs for frequently accessed records
class User < ApplicationRecord
  include OpaqueId::Model

  def opaque_id
    @opaque_id ||= super
  end
end
```

### 3. Background Generation

```ruby
# Generate IDs in background for bulk operations
class BulkUserCreator
  def self.create_users(count)
    # Generate IDs in background
    ids = Concurrent::Future.execute do
      count.times.map { OpaqueId.generate }
    end

    # Create users with pre-generated IDs
    users_data = ids.value.map.with_index do |id, index|
      { opaque_id: id, name: "User #{index + 1}" }
    end

    User.insert_all(users_data)
  end
end
```

### 4. Error Handling

```ruby
# Handle generation failures gracefully
class User < ApplicationRecord
  include OpaqueId::Model

  private

  def set_opaque_id
    retries = 0
    max_retries = opaque_id_max_retry

    begin
      self.opaque_id = generate_opaque_id
    rescue OpaqueId::GenerationError => e
      retries += 1
      if retries < max_retries
        retry
      else
        Rails.logger.error "Failed to generate opaque_id after #{max_retries} retries: #{e.message}"
        raise
      end
    end
  end
end
```

## Best Practices

### 1. Choose Appropriate Configuration

```ruby
# High-performance applications
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
self.opaque_id_length = 21

# High-security applications
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
self.opaque_id_length = 32

# Human-readable applications
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
self.opaque_id_length = 15
```

### 2. Optimize for Your Use Case

```ruby
# Short URLs - prioritize performance
self.opaque_id_length = 8
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

# API keys - prioritize security
self.opaque_id_length = 32
self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

# User IDs - balance performance and security
self.opaque_id_length = 21
self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
```

### 3. Monitor Performance

```ruby
# Add performance monitoring
# Track generation time
# Monitor memory usage
# Alert on slow generation
# Log performance metrics
```

## Next Steps

Now that you understand performance characteristics:

1. **Explore [Algorithms](algorithms.md)** for technical algorithm details
2. **Check out [Security](security.md)** for security considerations
3. **Review [Configuration](configuration.md)** for performance optimization
4. **Read [API Reference](api-reference.md)** for complete performance documentation
