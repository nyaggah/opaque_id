# frozen_string_literal: true

require 'test_helper'
require 'rails/generators'
require 'generators/opaque_id/install_generator'

class InstallGeneratorTest < Minitest::Test
  def setup
    @temp_dir = Dir.mktmpdir('opaque_id_test')
    @original_dir = Dir.pwd
    Dir.chdir(@temp_dir)

    # Create a minimal Rails app structure
    FileUtils.mkdir_p('app/models')
    FileUtils.mkdir_p('db/migrate')
    FileUtils.mkdir_p('config')

    # Create a test model file
    File.write('app/models/user.rb', <<~RUBY)
      class User < ApplicationRecord
        # Some existing code
      end
    RUBY

    # Create a test model file that already includes the concern
    File.write('app/models/post.rb', <<~RUBY)
      class Post < ApplicationRecord
        include OpaqueId::Model
        # Some existing code
      end
    RUBY
  end

  def teardown
    Dir.chdir(@original_dir) if @original_dir
    FileUtils.rm_rf(@temp_dir) if @temp_dir
  end

  private

  def create_generator(table_name = 'users', options = {})
    OpaqueId::Generators::InstallGenerator.new([table_name], options)
  end

  def test_generator_requires_table_name_argument
    assert_raises(ArgumentError) do
      OpaqueId::Generators::InstallGenerator.new.invoke_all
    end
  end

  def test_generator_creates_migration_file
    generator = create_generator('users')
    generator.invoke_all

    migration_files = Dir.glob('db/migrate/*_add_opaque_id_to_users.rb')
    assert_equal 1, migration_files.length

    migration_content = File.read(migration_files.first)
    assert_includes migration_content, 'class AddOpaqueIdToUsers'
    assert_includes migration_content, 'add_column :users, :opaque_id, :string'
    assert_includes migration_content, 'add_index :users, :opaque_id, unique: true'
  end

  def test_generator_creates_migration_with_custom_column_name
    generator = create_generator('users', { column_name: 'public_id' })
    generator.invoke_all

    migration_files = Dir.glob('db/migrate/*_add_opaque_id_to_users.rb')
    migration_content = File.read(migration_files.first)

    assert_includes migration_content, 'add_column :users, :public_id, :string'
    assert_includes migration_content, 'add_index :users, :public_id, unique: true'
  end

  def test_generator_adds_include_to_model_file
    generator = create_generator('users')
    generator.invoke_all

    model_content = File.read('app/models/user.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_model_file_not_found
    generator = create_generator('nonexistent')
    generator.invoke_all

    # Should not raise error, just skip model modification
    # Migration should still be created
    migration_files = Dir.glob('db/migrate/*_add_opaque_id_to_nonexistent.rb')
    assert_equal 1, migration_files.length
  end

  def test_generator_handles_already_included_concern
    generator = create_generator('posts')
    generator.invoke_all

    model_content = File.read('app/models/post.rb')
    # Should not duplicate the include statement
    include_count = model_content.scan('include OpaqueId::Model').length
    assert_equal 1, include_count
  end

  def test_generator_handles_different_class_names
    # Create a model with different class name than table name
    File.write('app/models/admin_user.rb', <<~RUBY)
      class AdminUser < ApplicationRecord
        self.table_name = "users"
        # Some existing code
      end
    RUBY

    generator = create_generator('users')
    generator.invoke_all

    # Should still add include to the model file
    model_content = File.read('app/models/admin_user.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_empty_model_file
    File.write('app/models/empty.rb', '')

    generator = create_generator('empty')
    generator.invoke_all

    model_content = File.read('app/models/empty.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_model_with_comments_only
    File.write('app/models/comment_only.rb', <<~RUBY)
      # This is a comment
      # Another comment
    RUBY

    generator = create_generator('comment_only')
    generator.invoke_all

    model_content = File.read('app/models/comment_only.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_model_with_multiple_classes
    File.write('app/models/multi_class.rb', <<~RUBY)
      class MultiClass < ApplicationRecord
        # Some code
      end

      class AnotherClass
        # Some other code
      end
    RUBY

    generator = create_generator('multi_class')
    generator.invoke_all

    model_content = File.read('app/models/multi_class.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_model_with_inheritance
    File.write('app/models/inherited.rb', <<~RUBY)
      class Inherited < SomeBaseClass
        # Some code
      end
    RUBY

    generator = create_generator('inherited')
    generator.invoke_all

    model_content = File.read('app/models/inherited.rb')
    assert_includes model_content, 'include OpaqueId::Model'
  end

  def test_generator_handles_model_with_includes_already
    File.write('app/models/with_includes.rb', <<~RUBY)
      class WithIncludes < ApplicationRecord
        include SomeOtherConcern
        include AnotherConcern
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_includes')
    generator.invoke_all

    model_content = File.read('app/models/with_includes.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'include SomeOtherConcern'
    assert_includes model_content, 'include AnotherConcern'
  end

  def test_generator_handles_model_with_methods
    File.write('app/models/with_methods.rb', <<~RUBY)
      class WithMethods < ApplicationRecord
        def some_method
          # Some code
        end
      #{'  '}
        private
      #{'  '}
        def private_method
          # Some code
        end
      end
    RUBY

    generator = create_generator('with_methods')
    generator.invoke_all

    model_content = File.read('app/models/with_methods.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'def some_method'
    assert_includes model_content, 'def private_method'
  end

  def test_generator_handles_model_with_attributes
    File.write('app/models/with_attributes.rb', <<~RUBY)
      class WithAttributes < ApplicationRecord
        attribute :custom_attr, :string
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_attributes')
    generator.invoke_all

    model_content = File.read('app/models/with_attributes.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'attribute :custom_attr, :string'
  end

  def test_generator_handles_model_with_validations
    File.write('app/models/with_validations.rb', <<~RUBY)
      class WithValidations < ApplicationRecord
        validates :name, presence: true
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_validations')
    generator.invoke_all

    model_content = File.read('app/models/with_validations.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'validates :name, presence: true'
  end

  def test_generator_handles_model_with_associations
    File.write('app/models/with_associations.rb', <<~RUBY)
      class WithAssociations < ApplicationRecord
        has_many :posts
        belongs_to :user
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_associations')
    generator.invoke_all

    model_content = File.read('app/models/with_associations.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'has_many :posts'
    assert_includes model_content, 'belongs_to :user'
  end

  def test_generator_handles_model_with_scopes
    File.write('app/models/with_scopes.rb', <<~RUBY)
      class WithScopes < ApplicationRecord
        scope :active, -> { where(active: true) }
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_scopes')
    generator.invoke_all

    model_content = File.read('app/models/with_scopes.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'scope :active, -> { where(active: true) }'
  end

  def test_generator_handles_model_with_callbacks
    File.write('app/models/with_callbacks.rb', <<~RUBY)
      class WithCallbacks < ApplicationRecord
        before_save :do_something
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_callbacks')
    generator.invoke_all

    model_content = File.read('app/models/with_callbacks.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'before_save :do_something'
  end

  def test_generator_handles_model_with_constants
    File.write('app/models/with_constants.rb', <<~RUBY)
      class WithConstants < ApplicationRecord
        STATUS_ACTIVE = "active"
        STATUS_INACTIVE = "inactive"
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_constants')
    generator.invoke_all

    model_content = File.read('app/models/with_constants.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'STATUS_ACTIVE = "active"'
    assert_includes model_content, 'STATUS_INACTIVE = "inactive"'
  end

  def test_generator_handles_model_with_comments
    File.write('app/models/with_comments.rb', <<~RUBY)
      class WithComments < ApplicationRecord
        # This is a comment
        # Another comment
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_comments')
    generator.invoke_all

    model_content = File.read('app/models/with_comments.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '# This is a comment'
    assert_includes model_content, '# Another comment'
  end

  def test_generator_handles_model_with_multiline_strings
    File.write('app/models/with_multiline.rb', <<~RUBY)
      class WithMultiline < ApplicationRecord
        def some_method
          <<~TEXT
            This is a multiline string
            with multiple lines
          TEXT
        end
      end
    RUBY

    generator = create_generator('with_multiline')
    generator.invoke_all

    model_content = File.read('app/models/with_multiline.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'This is a multiline string'
    assert_includes model_content, 'with multiple lines'
  end

  def test_generator_handles_model_with_symbols
    File.write('app/models/with_symbols.rb', <<~RUBY)
      class WithSymbols < ApplicationRecord
        def some_method
          :symbol
        end
      end
    RUBY

    generator = create_generator('with_symbols')
    generator.invoke_all

    model_content = File.read('app/models/with_symbols.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, ':symbol'
  end

  def test_generator_handles_model_with_numbers
    File.write('app/models/with_numbers.rb', <<~RUBY)
      class WithNumbers < ApplicationRecord
        def some_method
          42
          3.14
        end
      end
    RUBY

    generator = create_generator('with_numbers')
    generator.invoke_all

    model_content = File.read('app/models/with_numbers.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '42'
    assert_includes model_content, '3.14'
  end

  def test_generator_handles_model_with_arrays
    File.write('app/models/with_arrays.rb', <<~RUBY)
      class WithArrays < ApplicationRecord
        def some_method
          [1, 2, 3]
          %w[a b c]
        end
      end
    RUBY

    generator = create_generator('with_arrays')
    generator.invoke_all

    model_content = File.read('app/models/with_arrays.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '[1, 2, 3]'
    assert_includes model_content, '%w[a b c]'
  end

  def test_generator_handles_model_with_hashes
    File.write('app/models/with_hashes.rb', <<~RUBY)
      class WithHashes < ApplicationRecord
        def some_method
          { key: "value" }
          { "key" => "value" }
        end
      end
    RUBY

    generator = create_generator('with_hashes')
    generator.invoke_all

    model_content = File.read('app/models/with_hashes.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '{ key: "value" }'
    assert_includes model_content, '{ "key" => "value" }'
  end

  def test_generator_handles_model_with_regex
    File.write('app/models/with_regex.rb', <<~RUBY)
      class WithRegex < ApplicationRecord
        def some_method
          /pattern/
          %r{pattern}
        end
      end
    RUBY

    generator = create_generator('with_regex')
    generator.invoke_all

    model_content = File.read('app/models/with_regex.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '/pattern/'
    assert_includes model_content, '%r{pattern}'
  end

  def test_generator_handles_model_with_blocks
    File.write('app/models/with_blocks.rb', <<~RUBY)
      class WithBlocks < ApplicationRecord
        def some_method
          [1, 2, 3].each do |item|
            puts item
          end
        end
      end
    RUBY

    generator = create_generator('with_blocks')
    generator.invoke_all

    model_content = File.read('app/models/with_blocks.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, '[1, 2, 3].each do |item|'
    assert_includes model_content, 'puts item'
  end

  def test_generator_handles_model_with_conditionals
    File.write('app/models/with_conditionals.rb', <<~RUBY)
      class WithConditionals < ApplicationRecord
        def some_method
          if condition
            do_something
          elsif other_condition
            do_something_else
          else
            do_default
          end
        end
      end
    RUBY

    generator = create_generator('with_conditionals')
    generator.invoke_all

    model_content = File.read('app/models/with_conditionals.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'if condition'
    assert_includes model_content, 'elsif other_condition'
    assert_includes model_content, 'else'
  end

  def test_generator_handles_model_with_loops
    File.write('app/models/with_loops.rb', <<~RUBY)
      class WithLoops < ApplicationRecord
        def some_method
          while condition
            do_something
          end
      #{'    '}
          until other_condition
            do_something_else
          end
        end
      end
    RUBY

    generator = create_generator('with_loops')
    generator.invoke_all

    model_content = File.read('app/models/with_loops.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'while condition'
    assert_includes model_content, 'until other_condition'
  end

  def test_generator_handles_model_with_case_statements
    File.write('app/models/with_case.rb', <<~RUBY)
      class WithCase < ApplicationRecord
        def some_method
          case value
          when 1
            do_one
          when 2
            do_two
          else
            do_default
          end
        end
      end
    RUBY

    generator = create_generator('with_case')
    generator.invoke_all

    model_content = File.read('app/models/with_case.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'case value'
    assert_includes model_content, 'when 1'
    assert_includes model_content, 'when 2'
    assert_includes model_content, 'else'
  end

  def test_generator_handles_model_with_rescue
    File.write('app/models/with_rescue.rb', <<~RUBY)
      class WithRescue < ApplicationRecord
        def some_method
          begin
            risky_operation
          rescue StandardError => e
            handle_error(e)
          ensure
            cleanup
          end
        end
      end
    RUBY

    generator = create_generator('with_rescue')
    generator.invoke_all

    model_content = File.read('app/models/with_rescue.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'begin'
    assert_includes model_content, 'rescue StandardError => e'
    assert_includes model_content, 'ensure'
  end

  def test_generator_handles_model_with_class_methods
    File.write('app/models/with_class_methods.rb', <<~RUBY)
      class WithClassMethods < ApplicationRecord
        def self.class_method
          # Some code
        end
      #{'  '}
        def instance_method
          # Some code
        end
      end
    RUBY

    generator = create_generator('with_class_methods')
    generator.invoke_all

    model_content = File.read('app/models/with_class_methods.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'def self.class_method'
    assert_includes model_content, 'def instance_method'
  end

  def test_generator_handles_model_with_private_methods
    File.write('app/models/with_private.rb', <<~RUBY)
      class WithPrivate < ApplicationRecord
        def public_method
          # Some code
        end
      #{'  '}
        private
      #{'  '}
        def private_method
          # Some code
        end
      end
    RUBY

    generator = create_generator('with_private')
    generator.invoke_all

    model_content = File.read('app/models/with_private.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'def public_method'
    assert_includes model_content, 'private'
    assert_includes model_content, 'def private_method'
  end

  def test_generator_handles_model_with_protected_methods
    File.write('app/models/with_protected.rb', <<~RUBY)
      class WithProtected < ApplicationRecord
        def public_method
          # Some code
        end
      #{'  '}
        protected
      #{'  '}
        def protected_method
          # Some code
        end
      end
    RUBY

    generator = create_generator('with_protected')
    generator.invoke_all

    model_content = File.read('app/models/with_protected.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'def public_method'
    assert_includes model_content, 'protected'
    assert_includes model_content, 'def protected_method'
  end

  def test_generator_handles_model_with_modules
    File.write('app/models/with_modules.rb', <<~RUBY)
      class WithModules < ApplicationRecord
        include SomeModule
        extend AnotherModule
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_modules')
    generator.invoke_all

    model_content = File.read('app/models/with_modules.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'include SomeModule'
    assert_includes model_content, 'extend AnotherModule'
  end

  def test_generator_handles_model_with_delegations
    File.write('app/models/with_delegations.rb', <<~RUBY)
      class WithDelegations < ApplicationRecord
        delegate :method, to: :object
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_delegations')
    generator.invoke_all

    model_content = File.read('app/models/with_delegations.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'delegate :method, to: :object'
  end

  def test_generator_handles_model_with_aliases
    File.write('app/models/with_aliases.rb', <<~RUBY)
      class WithAliases < ApplicationRecord
        alias_method :new_name, :old_name
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_aliases')
    generator.invoke_all

    model_content = File.read('app/models/with_aliases.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'alias_method :new_name, :old_name'
  end

  def test_generator_handles_model_with_metaclass
    File.write('app/models/with_metaclass.rb', <<~RUBY)
      class WithMetaclass < ApplicationRecord
        class << self
          def metaclass_method
            # Some code
          end
        end
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_metaclass')
    generator.invoke_all

    model_content = File.read('app/models/with_metaclass.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'class << self'
    assert_includes model_content, 'def metaclass_method'
  end

  def test_generator_handles_model_with_nested_classes
    File.write('app/models/with_nested.rb', <<~RUBY)
      class WithNested < ApplicationRecord
        class NestedClass
          # Some code
        end
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_nested')
    generator.invoke_all

    model_content = File.read('app/models/with_nested.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'class NestedClass'
  end

  def test_generator_handles_model_with_nested_modules
    File.write('app/models/with_nested_module.rb', <<~RUBY)
      class WithNestedModule < ApplicationRecord
        module NestedModule
          # Some code
        end
      #{'  '}
        # Some code
      end
    RUBY

    generator = create_generator('with_nested_module')
    generator.invoke_all

    model_content = File.read('app/models/with_nested_module.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'module NestedModule'
  end

  def test_generator_handles_model_with_constants_and_methods
    File.write('app/models/with_constants_and_methods.rb', <<~RUBY)
      class WithConstantsAndMethods < ApplicationRecord
        CONSTANT = "value"
      #{'  '}
        def method1
          # Some code
        end
      #{'  '}
        CONSTANT2 = "value2"
      #{'  '}
        def method2
          # Some code
        end
      end
    RUBY

    generator = create_generator('with_constants_and_methods')
    generator.invoke_all

    model_content = File.read('app/models/with_constants_and_methods.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'CONSTANT = "value"'
    assert_includes model_content, 'def method1'
    assert_includes model_content, 'CONSTANT2 = "value2"'
    assert_includes model_content, 'def method2'
  end

  def test_generator_handles_model_with_complex_structure
    File.write('app/models/complex.rb', <<~RUBY)
      class Complex < ApplicationRecord
        include SomeConcern
        extend AnotherConcern
      #{'  '}
        CONSTANT = "value"
      #{'  '}
        validates :name, presence: true
      #{'  '}
        scope :active, -> { where(active: true) }
      #{'  '}
        has_many :posts
        belongs_to :user
      #{'  '}
        before_save :do_something
      #{'  '}
        def public_method
          # Some code
        end
      #{'  '}
        private
      #{'  '}
        def private_method
          # Some code
        end
      #{'  '}
        protected
      #{'  '}
        def protected_method
          # Some code
        end
      end
    RUBY

    generator = create_generator('complex')
    generator.invoke_all

    model_content = File.read('app/models/complex.rb')
    assert_includes model_content, 'include OpaqueId::Model'
    assert_includes model_content, 'include SomeConcern'
    assert_includes model_content, 'extend AnotherConcern'
    assert_includes model_content, 'CONSTANT = "value"'
    assert_includes model_content, 'validates :name, presence: true'
    assert_includes model_content, 'scope :active, -> { where(active: true) }'
    assert_includes model_content, 'has_many :posts'
    assert_includes model_content, 'belongs_to :user'
    assert_includes model_content, 'before_save :do_something'
    assert_includes model_content, 'def public_method'
    assert_includes model_content, 'private'
    assert_includes model_content, 'def private_method'
    assert_includes model_content, 'protected'
    assert_includes model_content, 'def protected_method'
  end
end
