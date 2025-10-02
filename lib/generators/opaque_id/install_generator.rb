# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

module OpaqueId
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      argument :table_name, type: :string, default: nil, banner: 'table_name'

      class_option :column_name, type: :string, default: 'opaque_id',
                                 desc: 'Name of the column to add'

      def create_migration_file
        if table_name.present?
          migration_template 'migration.rb.tt',
                             "db/migrate/add_opaque_id_to_#{table_name}.rb"

          add_include_to_model
        else
          say 'Usage: rails generate opaque_id:install TABLE_NAME', :red
          say 'Example: rails generate opaque_id:install posts', :green
        end
      end

      private

      def add_include_to_model
        model_path = "app/models/#{table_name.singularize}.rb"

        if File.exist?(model_path)
          # Read existing model file
          content = File.read(model_path)

          # Check if already included
          if content.include?('include OpaqueId::Model')
            say "OpaqueId::Model already included in #{model_path}", :yellow
          else
            # Add include statement
            content.gsub!(/class #{table_name.classify} < ApplicationRecord/,
                          "class #{table_name.classify} < ApplicationRecord\n  include OpaqueId::Model")

            # Write back to file
            File.write(model_path, content)
            say "Updated #{model_path}", :green
          end
        else
          say "Model file #{model_path} not found. Please add 'include OpaqueId::Model' manually.", :yellow
        end
      end
    end
  end
end
