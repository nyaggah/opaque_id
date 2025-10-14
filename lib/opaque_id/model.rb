# frozen_string_literal: true

require 'active_support/concern'

module OpaqueId
  module Model
    extend ActiveSupport::Concern

    included do
      before_create :set_opaque_id
    end

    class_methods do
      def find_by_opaque_id(opaque_id)
        where(opaque_id_column => opaque_id).first
      end

      def find_by_opaque_id!(opaque_id)
        find_by_opaque_id(opaque_id) || raise(ActiveRecord::RecordNotFound,
                                              "Couldn't find #{name} with opaque_id=#{opaque_id}")
      end

      # Configuration options
      def opaque_id_column
        @opaque_id_column ||= OpaqueId.configuration.default_column
      end

      def opaque_id_column=(value)
        @opaque_id_column = value
      end

      def opaque_id_length
        @opaque_id_length ||= OpaqueId.configuration.default_length
      end

      def opaque_id_length=(value)
        @opaque_id_length = value
      end

      def opaque_id_alphabet
        @opaque_id_alphabet ||= OpaqueId.configuration.default_alphabet
      end

      def opaque_id_alphabet=(value)
        @opaque_id_alphabet = value
      end

      def opaque_id_require_letter_start
        @opaque_id_require_letter_start ||= OpaqueId.configuration.default_require_letter_start
      end

      def opaque_id_require_letter_start=(value)
        @opaque_id_require_letter_start = value
      end

      def opaque_id_purge_chars
        @opaque_id_purge_chars ||= OpaqueId.configuration.default_purge_chars
      end

      def opaque_id_purge_chars=(value)
        @opaque_id_purge_chars = value
      end

      def opaque_id_max_retry
        @opaque_id_max_retry ||= OpaqueId.configuration.default_max_retry
      end

      def opaque_id_max_retry=(value)
        @opaque_id_max_retry = value
      end
    end

    private

    def set_opaque_id
      return if send(opaque_id_column).present?

      opaque_id_max_retry.times do
        generated_id = generate_opaque_id
        send("#{opaque_id_column}=", generated_id)
        return unless self.class.where(opaque_id_column => generated_id).exists?
      end
      raise GenerationError, "Failed to generate a unique opaque_id after #{opaque_id_max_retry} attempts"
    end

    def generate_opaque_id
      loop do
        id = OpaqueId.generate(
          size: opaque_id_length,
          alphabet: opaque_id_alphabet
        )

        # Apply letter start requirement
        next if opaque_id_require_letter_start && !id.match?(/\A[A-Za-z]/)

        # Apply character purging
        if opaque_id_purge_chars.any?
          id = id.chars.reject { |char| opaque_id_purge_chars.include?(char) }.join
          next if id.length < opaque_id_length
        end

        return id
      end
    end

    def opaque_id_column
      self.class.opaque_id_column
    end

    def opaque_id_length
      self.class.opaque_id_length
    end

    def opaque_id_alphabet
      self.class.opaque_id_alphabet
    end

    def opaque_id_max_retry
      self.class.opaque_id_max_retry
    end

    def opaque_id_require_letter_start
      self.class.opaque_id_require_letter_start
    end

    def opaque_id_purge_chars
      self.class.opaque_id_purge_chars
    end
  end
end
