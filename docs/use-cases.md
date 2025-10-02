---
layout: default
title: Use Cases
nav_order: 10
description: "Real-world examples and applications for OpaqueId"
permalink: /use-cases/
---

# Use Cases

OpaqueId is designed for a wide range of applications where secure, unpredictable identifiers are needed. This guide covers real-world use cases with practical examples and implementation patterns.

- TOC
{:toc}

## E-Commerce Applications

### Order Management

E-commerce platforms need secure order identifiers that don't reveal business information.

```ruby
class Order < ApplicationRecord
  include OpaqueId::Model

  # Short, numeric order numbers for customer service
  self.opaque_id_column = :order_number
  self.opaque_id_length = 8
  self.opaque_id_alphabet = "0123456789"
end

# Usage
order = Order.create!(user_id: 1, total: 99.99)
puts order.order_number
# => "12345678"

# Customer service can reference orders easily
# "Please provide order number 12345678"
```

### Product Management

Products need secure identifiers for inventory and catalog management.

```ruby
class Product < ApplicationRecord
  include OpaqueId::Model

  # Medium-length alphanumeric SKUs
  self.opaque_id_column = :sku
  self.opaque_id_length = 12
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
product = Product.create!(name: "Wireless Headphones", price: 199.99)
puts product.sku
# => "V1StGXR8_Z5j"

# Inventory management
# "SKU V1StGXR8_Z5j is out of stock"
```

### Customer Management

Customer accounts need secure identifiers for privacy and security.

```ruby
class Customer < ApplicationRecord
  include OpaqueId::Model

  # Standard length for customer IDs
  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
customer = Customer.create!(name: "John Doe", email: "john@example.com")
puts customer.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"

# Customer support
# "Customer ID V1StGXR8_Z5jdHi6B-myT has an issue with order 12345678"
```

## API Development

### API Key Management

APIs need secure keys for authentication and authorization.

```ruby
class ApiKey < ApplicationRecord
  include OpaqueId::Model

  # Long, secure API keys
  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  self.opaque_id_require_letter_start = true
end

# Usage
api_key = ApiKey.create!(user_id: 1, name: "Mobile App")
puts api_key.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT1234567890"

# API authentication
# Authorization: Bearer V1StGXR8_Z5jdHi6B-myT1234567890
```

### API Token Management

Short-lived tokens for session management and temporary access.

```ruby
class ApiToken < ApplicationRecord
  include OpaqueId::Model

  # Medium-length tokens
  self.opaque_id_column = :token
  self.opaque_id_length = 24
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
token = ApiToken.create!(user_id: 1, expires_at: 1.hour.from_now)
puts token.token
# => "V1StGXR8_Z5jdHi6B-myT123"

# API requests
# Authorization: Token V1StGXR8_Z5jdHi6B-myT123
```

### Webhook Management

Webhooks need secure identifiers for verification and tracking.

```ruby
class Webhook < ApplicationRecord
  include OpaqueId::Model

  # Medium-length webhook IDs
  self.opaque_id_length = 16
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
webhook = Webhook.create!(url: "https://example.com/webhook", events: ["order.created"])
puts webhook.opaque_id
# => "V1StGXR8_Z5jdHi"

# Webhook delivery
# POST https://example.com/webhook
# X-Webhook-ID: V1StGXR8_Z5jdHi
```

## Content Management Systems

### Article Management

Articles need URL-friendly identifiers for SEO and sharing.

```ruby
class Article < ApplicationRecord
  include OpaqueId::Model

  # Short, URL-safe slugs
  self.opaque_id_column = :slug
  self.opaque_id_length = 8
  self.opaque_id_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
end

# Usage
article = Article.create!(title: "Getting Started with OpaqueId", content: "...")
puts article.slug
# => "V1StGXR8"

# URL generation
# https://example.com/articles/V1StGXR8
```

### Comment Management

Comments need secure identifiers for moderation and tracking.

```ruby
class Comment < ApplicationRecord
  include OpaqueId::Model

  # Standard length for comments
  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
comment = Comment.create!(article_id: 1, user_id: 1, content: "Great article!")
puts comment.opaque_id
# => "V1StGXR8_Z5jdHi"

# Comment moderation
# "Comment V1StGXR8_Z5jdHi needs review"
```

### Media Management

Media files need secure identifiers for access control and tracking.

```ruby
class MediaFile < ApplicationRecord
  include OpaqueId::Model

  # Medium-length media IDs
  self.opaque_id_length = 18
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
media = MediaFile.create!(filename: "image.jpg", size: 1024000)
puts media.opaque_id
# => "V1StGXR8_Z5jdHi6B-my"

# Media access
# https://example.com/media/V1StGXR8_Z5jdHi6B-my
```

## User Management

### User Accounts

User accounts need secure identifiers for privacy and security.

```ruby
class User < ApplicationRecord
  include OpaqueId::Model

  # Standard length for user IDs
  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
user = User.create!(name: "John Doe", email: "john@example.com")
puts user.opaque_id
# => "V1StGXR8_Z5jdHi6B-myT"

# User profile URLs
# https://example.com/users/V1StGXR8_Z5jdHi6B-myT
```

### User Sessions

Sessions need secure identifiers for tracking and management.

```ruby
class UserSession < ApplicationRecord
  include OpaqueId::Model

  # Long, secure session IDs
  self.opaque_id_column = :session_id
  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
session = UserSession.create!(user_id: 1, expires_at: 30.days.from_now)
puts session.session_id
# => "V1StGXR8_Z5jdHi6B-myT1234567890"

# Session management
# "Session V1StGXR8_Z5jdHi6B-myT1234567890 expired"
```

### User Preferences

User preferences need secure identifiers for privacy.

```ruby
class UserPreference < ApplicationRecord
  include OpaqueId::Model

  # Medium-length preference IDs
  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
preference = UserPreference.create!(user_id: 1, key: "theme", value: "dark")
puts preference.opaque_id
# => "V1StGXR8_Z5jdHi"

# Preference management
# "Preference V1StGXR8_Z5jdHi updated"
```

## Background Job Systems

### Job Management

Background jobs need secure identifiers for tracking and debugging.

```ruby
class BackgroundJob < ApplicationRecord
  include OpaqueId::Model

  # Medium-length job IDs
  self.opaque_id_length = 18
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
job = BackgroundJob.create!(job_type: "email_delivery", status: "pending")
puts job.opaque_id
# => "V1StGXR8_Z5jdHi6B-my"

# Job monitoring
# "Job V1StGXR8_Z5jdHi6B-my failed after 3 retries"
```

### Queue Management

Message queues need secure identifiers for message tracking.

```ruby
class QueueMessage < ApplicationRecord
  include OpaqueId::Model

  # Medium-length message IDs
  self.opaque_id_length = 16
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
message = QueueMessage.create!(queue_name: "email_queue", payload: {...})
puts message.opaque_id
# => "V1StGXR8_Z5jdHi"

# Message processing
# "Message V1StGXR8_Z5jdHi processed successfully"
```

## Short URL Services

### URL Shortening

Short URLs need compact, secure identifiers.

```ruby
class ShortUrl < ApplicationRecord
  include OpaqueId::Model

  # Very short URLs for sharing
  self.opaque_id_length = 6
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
short_url = ShortUrl.create!(original_url: "https://example.com/very/long/url")
puts short_url.opaque_id
# => "V1StGX"

# Short URL generation
# https://short.ly/V1StGX
```

### URL Analytics

URL analytics need secure identifiers for tracking.

```ruby
class UrlAnalytic < ApplicationRecord
  include OpaqueId::Model

  # Medium-length analytic IDs
  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
analytic = UrlAnalytic.create!(short_url_id: 1, ip_address: "192.168.1.1")
puts analytic.opaque_id
# => "V1StGXR8_Z5jdHi"

# Analytics tracking
# "Analytic V1StGXR8_Z5jdHi recorded for URL V1StGX"
```

## Real-Time Applications

### Chat Systems

Chat messages need secure identifiers for real-time communication.

```ruby
class ChatMessage < ApplicationRecord
  include OpaqueId::Model

  # Medium-length message IDs
  self.opaque_id_length = 18
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
message = ChatMessage.create!(room_id: 1, user_id: 1, content: "Hello!")
puts message.opaque_id
# => "V1StGXR8_Z5jdHi6B-my"

# Real-time messaging
# "Message V1StGXR8_Z5jdHi6B-my sent to room 1"
```

### Notification Systems

Notifications need secure identifiers for delivery tracking.

```ruby
class Notification < ApplicationRecord
  include OpaqueId::Model

  # Medium-length notification IDs
  self.opaque_id_length = 16
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
notification = Notification.create!(user_id: 1, type: "email", content: "New message")
puts notification.opaque_id
# => "V1StGXR8_Z5jdHi"

# Notification delivery
# "Notification V1StGXR8_Z5jdHi delivered to user 1"
```

## Analytics and Tracking

### Event Tracking

Events need secure identifiers for analytics and tracking.

```ruby
class Event < ApplicationRecord
  include OpaqueId::Model

  # Medium-length event IDs
  self.opaque_id_length = 15
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end

# Usage
event = Event.create!(user_id: 1, event_type: "page_view", properties: {...})
puts event.opaque_id
# => "V1StGXR8_Z5jdHi"

# Event tracking
# "Event V1StGXR8_Z5jdHi recorded for user 1"
```

### Conversion Tracking

Conversions need secure identifiers for attribution and analysis.

```ruby
class Conversion < ApplicationRecord
  include OpaqueId::Model

  # Medium-length conversion IDs
  self.opaque_id_length = 18
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end

# Usage
conversion = Conversion.create!(user_id: 1, campaign_id: 1, value: 99.99)
puts conversion.opaque_id
# => "V1StGXR8_Z5jdHi6B-my"

# Conversion tracking
# "Conversion V1StGXR8_Z5jdHi6B-my attributed to campaign 1"
```

## Use Case Summary

### Security Levels

| Use Case      | ID Length | Alphabet     | Security Level | Example                         |
| ------------- | --------- | ------------ | -------------- | ------------------------------- |
| API Keys      | 32        | Alphanumeric | Very High      | V1StGXR8_Z5jdHi6B-myT1234567890 |
| User IDs      | 21        | Standard     | High           | V1StGXR8_Z5jdHi6B-myT           |
| Order Numbers | 8         | Numeric      | Medium         | 12345678                        |
| Short URLs    | 6         | Alphanumeric | Low            | V1StGX                          |

### Performance Considerations

| Use Case      | Volume        | Performance         | Memory |
| ------------- | ------------- | ------------------- | ------ |
| High Volume   | 1M+ IDs/day   | Fast Path (64-char) | Low    |
| Medium Volume | 100K+ IDs/day | Standard Path       | Low    |
| Low Volume    | <100K IDs/day | Any Path            | Low    |

### Implementation Patterns

#### 1. High Security Applications

```ruby
# API keys, authentication tokens, sensitive data
class SecureResource < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 32
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
  self.opaque_id_require_letter_start = true
end
```

#### 2. General Purpose Applications

```ruby
# User IDs, content IDs, general identifiers
class GeneralResource < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 21
  self.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
end
```

#### 3. Public-Facing Applications

```ruby
# URLs, public identifiers, user-facing IDs
class PublicResource < ApplicationRecord
  include OpaqueId::Model

  self.opaque_id_length = 8
  self.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET
end
```

## Best Practices by Use Case

### 1. Choose Appropriate Length

- **High Security**: 21+ characters
- **Medium Security**: 15+ characters
- **Low Security**: 8+ characters

### 2. Select Suitable Alphabet

- **URL-Safe**: Alphanumeric or Standard
- **Human-Readable**: Alphanumeric
- **High Performance**: Standard (64 characters)
- **Numeric Only**: Custom numeric alphabet

### 3. Consider Performance Requirements

- **High Volume**: Use 64-character alphabets
- **Medium Volume**: Use standard alphabets
- **Low Volume**: Any alphabet works

### 4. Implement Proper Security

- **Authentication**: Required for sensitive resources
- **Authorization**: Check access permissions
- **Rate Limiting**: Prevent abuse
- **Monitoring**: Track usage patterns

## Next Steps

Now that you understand use cases:

1. **Explore [Configuration](configuration.md)** for use case-specific configuration
2. **Check out [Security](security.md)** for security considerations
3. **Review [Performance](performance.md)** for performance optimization
4. **Read [API Reference](api-reference.md)** for complete implementation details
