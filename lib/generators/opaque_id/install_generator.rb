# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module OpaqueId
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      argument :model_name, type: :string, default: nil, banner: 'ModelName'

      class_option :column_name, type: :string, default: 'opaque_id',
                                 desc: 'Name of the column to add'

      def create_migration_file
        if model_name.present?
          table_name = model_name.tableize
          migration_template 'migration.rb.tt',
                             "db/migrate/add_opaque_id_to_#{table_name}.rb"

          add_include_to_model
        else
          say 'Usage: rails generate opaque_id:install ModelName', :red
          say 'Example: rails generate opaque_id:install User', :green
          say 'Example: rails generate opaque_id:install Post --column-name=public_id', :green
        end
      end

      private

      def add_include_to_model
        model_path = "app/models/#{model_name.underscore}.rb"

        if File.exist?(model_path)
          # Read existing model file
          content = File.read(model_path)

          # Check if already included
          if content.include?('include OpaqueId::Model')
            say "OpaqueId::Model already included in #{model_path}", :yellow
          else
            # Prepare the include statement with optional column configuration
            include_statement = '  include OpaqueId::Model'
            if options[:column_name] != 'opaque_id'
              include_statement += "\n  self.opaque_id_column = :#{options[:column_name]}"
            end

            # Add include statement and column configuration
            content.gsub!(/class #{model_name} < ApplicationRecord/,
                          "class #{model_name} < ApplicationRecord\n#{include_statement}")

            # Write back to file
            File.write(model_path, content)
            say "Updated #{model_path}", :green
            say "  Set opaque_id_column to :#{options[:column_name]}", :green if options[:column_name] != 'opaque_id'
          end
        else
          say "Model file #{model_path} not found. Please add 'include OpaqueId::Model' manually.", :yellow
        end
      end
    end
  end
end
