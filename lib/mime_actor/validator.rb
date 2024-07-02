# frozen_string_literal: true

# :markup: markdown

require "active_support/concern"
require "active_support/core_ext/object/blank"
require "set" # required by mime_type with ruby <= 3.1
require "action_dispatch/http/mime_type"

module MimeActor
  # # MimeActor Validator
  #
  # Validator provides validation rules for `action`, `format`, and `with` handlers by default.
  #
  # @example Raise error when rule is violated
  #   validate!(:action, action_param)
  #
  # @example Return the error when rule is violated
  #   ex = validate_action(action_param)
  #   raise ex if error
  #
  module Validator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :scene_formats, instance_writer: false, default: Mime::SET.symbols.to_set
    end

    module ClassMethods
      # Raise the error returned by validator if any.
      #
      # @param rule the name of validator
      def validate!(rule, *args)
        validator = "validate_#{rule}"
        raise NameError, "Validator not found, got: #{validator.inspect}" unless respond_to?(validator, true)

        error = send(validator, *args)
        raise error if error
      end

      # Validate `action` must be a Symbol
      #
      # @param unchecked the `action` to be validated
      def validate_action(unchecked)
        ArgumentError.new("action must be a Symbol") unless unchecked.is_a?(Symbol)
      end

      # Validate `actions` must be a collection of Symbol
      #
      # @param unchecked the `actions` to be validated
      def validate_actions(unchecked)
        rejected = unchecked.reject { |action| action.is_a?(Symbol) }
        NameError.new("invalid actions, got: #{rejected.map(&:inspect).join(", ")}") if rejected.size.positive?
      end

      # Validate `format` must be a Symbol and a valid MIME type
      #
      # @param unchecked the `format` to be validated
      def validate_format(unchecked)
        return ArgumentError.new("format must be a Symbol") unless unchecked.is_a?(Symbol)

        NameError.new("invalid format, got: #{unchecked.inspect}") unless scene_formats.include?(unchecked)
      end

      # Validate `formats` must be an collection of Symbol which each of them is a valid MIME type
      #
      # @param unchecked the `formats` to be validated
      def validate_formats(unchecked)
        unfiltered = unchecked.to_set
        filtered = unfiltered & scene_formats
        rejected = unfiltered - filtered

        NameError.new("invalid formats, got: #{rejected.map(&:inspect).join(", ")}") if rejected.size.positive?
      end

      # Validate `klazz` must be a Class/Module or a String referencing a Class/Module
      #
      # @param unchecked the `klazz` to be validated
      def validate_klazz(unchecked)
        return if unchecked.is_a?(Module) || unchecked.is_a?(String)

        ArgumentError.new("#{unchecked.inspect} must be a Class/Module or a String referencing a Class/Module")
      end

      # Validate `with` must be a Symbol or Proc
      #
      # @param unchecked the `with` to be validated
      def validate_with(unchecked)
        return if unchecked.is_a?(Proc) || unchecked.is_a?(Symbol)

        ArgumentError.new("with handler must be a Symbol or Proc, got: #{unchecked.inspect}")
      end
    end
  end
end
