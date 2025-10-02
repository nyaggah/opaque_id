# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'opaque_id'

require 'minitest/autorun'
require 'active_record'
require 'sqlite3'

# Set up test database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# Load Rails for generator tests
require 'rails'
require 'rails/generators'
require 'rails/generators/testing/assertions'
require 'rails/generators/testing/behavior'

# Configure Rails for testing
Rails.application = Class.new(Rails::Application) do
  config.eager_load = false
  config.active_support.deprecation = :stderr
  config.active_support.to_time_preserves_timezone = :zone
end

Rails.application.initialize!
