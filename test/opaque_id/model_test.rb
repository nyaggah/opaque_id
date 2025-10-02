# frozen_string_literal: true

require 'test_helper'

class OpaqueIdModelTest < Minitest::Test
  def setup
    # Create a test model class
    @model_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_models'
      include OpaqueId::Model
    end

    # Create test table
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS test_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        opaque_id VARCHAR(255)
      )
    SQL

    # Add unique index on opaque_id
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE UNIQUE INDEX IF NOT EXISTS index_test_models_on_opaque_id#{' '}
      ON test_models (opaque_id)
    SQL
  end

  def teardown
    # Clean up test table
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS test_models')
  end

  def test_model_includes_opaque_id_concern
    assert @model_class.ancestors.include?(OpaqueId::Model)
  end

  def test_default_configuration
    assert_equal :opaque_id, @model_class.opaque_id_column
    assert_equal 21, @model_class.opaque_id_length
    assert_equal OpaqueId::ALPHANUMERIC_ALPHABET, @model_class.opaque_id_alphabet
    assert_equal false, @model_class.opaque_id_require_letter_start
    assert_equal [], @model_class.opaque_id_purge_chars
    assert_equal 3, @model_class.opaque_id_max_retry
  end

  def test_custom_configuration
    @model_class.opaque_id_column = :public_id
    @model_class.opaque_id_length = 15
    @model_class.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET
    @model_class.opaque_id_require_letter_start = true
    @model_class.opaque_id_purge_chars = ['-', '_']
    @model_class.opaque_id_max_retry = 5

    assert_equal :public_id, @model_class.opaque_id_column
    assert_equal 15, @model_class.opaque_id_length
    assert_equal OpaqueId::STANDARD_ALPHABET, @model_class.opaque_id_alphabet
    assert_equal true, @model_class.opaque_id_require_letter_start
    assert_equal ['-', '_'], @model_class.opaque_id_purge_chars
    assert_equal 5, @model_class.opaque_id_max_retry
  end

  def test_automatic_opaque_id_generation_on_create
    model = @model_class.create!(name: 'Test Model')

    refute_nil model.opaque_id
    assert_equal 21, model.opaque_id.length
    assert_match(/\A[A-Za-z0-9]+\z/, model.opaque_id)
  end

  def test_opaque_id_not_generated_on_update
    model = @model_class.create!(name: 'Test Model')
    original_opaque_id = model.opaque_id

    model.update!(name: 'Updated Name')

    assert_equal original_opaque_id, model.opaque_id
  end

  def test_find_by_opaque_id
    model = @model_class.create!(name: 'Test Model')

    found_model = @model_class.find_by_opaque_id(model.opaque_id)
    assert_equal model, found_model
  end

  def test_find_by_opaque_id_returns_nil_for_nonexistent_id
    found_model = @model_class.find_by_opaque_id('nonexistent_id')
    assert_nil found_model
  end

  def test_find_by_opaque_id_bang
    model = @model_class.create!(name: 'Test Model')

    found_model = @model_class.find_by_opaque_id!(model.opaque_id)
    assert_equal model, found_model
  end

  def test_find_by_opaque_id_bang_raises_error_for_nonexistent_id
    assert_raises(ActiveRecord::RecordNotFound) do
      @model_class.find_by_opaque_id!('nonexistent_id')
    end
  end

  def test_custom_column_name
    @model_class.opaque_id_column = :public_id

    # Create table with public_id column
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS test_models_custom (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        public_id VARCHAR(255)
      )
    SQL

    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE UNIQUE INDEX IF NOT EXISTS index_test_models_custom_on_public_id#{' '}
      ON test_models_custom (public_id)
    SQL

    custom_model_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_models_custom'
      include OpaqueId::Model

      self.opaque_id_column = :public_id
    end

    model = custom_model_class.create!(name: 'Test Model')

    refute_nil model.public_id
    assert_equal 21, model.public_id.length

    found_model = custom_model_class.find_by_opaque_id(model.public_id)
    assert_equal model, found_model

    # Clean up
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS test_models_custom')
  end

  def test_custom_length
    @model_class.opaque_id_length = 15

    model = @model_class.create!(name: 'Test Model')

    assert_equal 15, model.opaque_id.length
  end

  def test_custom_alphabet
    @model_class.opaque_id_alphabet = 'ABCDEF'

    model = @model_class.create!(name: 'Test Model')

    assert_match(/\A[ABCDEF]+\z/, model.opaque_id)
  end

  def test_require_letter_start
    @model_class.opaque_id_require_letter_start = true
    @model_class.opaque_id_alphabet = OpaqueId::ALPHANUMERIC_ALPHABET

    # Generate multiple IDs to test the letter start requirement
    10.times do
      model = @model_class.create!(name: 'Test Model')
      assert_match(/\A[A-Za-z]/, model.opaque_id, 'Opaque ID should start with a letter')
    end
  end

  def test_purge_chars
    @model_class.opaque_id_purge_chars = ['-', '_']
    @model_class.opaque_id_alphabet = OpaqueId::STANDARD_ALPHABET

    # Generate multiple IDs to test character purging
    10.times do
      model = @model_class.create!(name: 'Test Model')
      refute_match(/[-_]/, model.opaque_id, 'Opaque ID should not contain purged characters')
    end
  end

  def test_collision_handling
    # Mock the generate method to return the same ID twice, then a different one
    call_count = 0
    @model_class.class_eval do
      define_method(:generate_opaque_id) do
        call_count += 1
        case call_count
        when 1, 2
          'collision_id'
        else
          'unique_id'
        end
      end
    end

    # Create first model
    model1 = @model_class.create!(name: 'Model 1')
    assert_equal 'collision_id', model1.opaque_id

    # Create second model (should handle collision and retry)
    model2 = @model_class.create!(name: 'Model 2')
    assert_equal 'unique_id', model2.opaque_id
  end

  def test_max_retry_exceeded_raises_error
    @model_class.opaque_id_max_retry = 2

    # Mock the generate method to always return the same ID
    @model_class.class_eval do
      define_method(:generate_opaque_id) do
        'always_same_id'
      end
    end

    # Create first model
    @model_class.create!(name: 'Model 1')

    # Second model should raise error after max retries
    assert_raises(OpaqueId::GenerationError) do
      @model_class.create!(name: 'Model 2')
    end
  end

  def test_instance_methods_work_with_configuration
    @model_class.opaque_id_column = :public_id
    @model_class.opaque_id_length = 15

    model = @model_class.new(name: 'Test Model')

    # Test that instance methods can access configuration
    assert_equal :public_id, model.send(:opaque_id_column)
    assert_equal 15, model.send(:opaque_id_length)
    assert_equal OpaqueId::ALPHANUMERIC_ALPHABET, model.send(:opaque_id_alphabet)
  end

  def test_multiple_models_with_different_configurations
    # Create another model class with different configuration
    other_model_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'other_test_models'
      include OpaqueId::Model

      self.opaque_id_length = 15
      self.opaque_id_alphabet = 'ABCDEF'
    end

    # Create table for other model
    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE TABLE IF NOT EXISTS other_test_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name VARCHAR(255),
        opaque_id VARCHAR(255)
      )
    SQL

    ActiveRecord::Base.connection.execute(<<~SQL)
      CREATE UNIQUE INDEX IF NOT EXISTS index_other_test_models_on_opaque_id#{' '}
      ON other_test_models (opaque_id)
    SQL

    model1 = @model_class.create!(name: 'Model 1')
    model2 = other_model_class.create!(name: 'Model 2')

    assert_equal 21, model1.opaque_id.length
    assert_equal 15, model2.opaque_id.length
    assert_match(/\A[A-Za-z0-9]+\z/, model1.opaque_id)
    assert_match(/\A[ABCDEF]+\z/, model2.opaque_id)

    # Clean up
    ActiveRecord::Base.connection.execute('DROP TABLE IF EXISTS other_test_models')
  end
end
