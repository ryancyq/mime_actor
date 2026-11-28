# frozen_string_literal: true

# :markup: markdown

require "active_support/core_ext/object/blank"
require "set" # required by mime_type with ruby <= 3.1
require "action_dispatch/http/mime_type"
require "action_pack/version"

module MimeActor
  # # MimeActor Validator
  #
  # Validator provides validation rules for `action`, `format`, and `with` handlers.
  #
  # @example Raise error when rule is violated
  #   MimeActor::Validator.validate!(:action, action_param)
  #
  # @example Return the error when rule is violated
  #   error = MimeActor::Validator.validate_action(action_param)
  #   raise error if error
  #
  module Validator
    module_function

    # Raise the error returned by validator if any.
    #
    # @param rule the name of validator
    def validate!(rule, *args)
      validator = "validate_#{rule}"
      raise NameError, "Validator not found, got: #{validator.inspect}" unless respond_to?(validator)

      error = public_send(validator, *args)
      raise error if error
    end

    # Validate `action` must be a Symbol
    #
    # @param unchecked the `action` to be validated
    def validate_action(unchecked)
      TypeError.new("action must be a Symbol") unless unchecked.is_a?(Symbol)
    end

    # Validate `actions` must be a collection of Symbol
    #
    # @param unchecked the `actions` to be validated
    def validate_actions(unchecked)
      return TypeError.new("actions must not be empty") if unchecked.empty?

      rejected = unchecked.grep_v(Symbol)
      NameError.new("invalid actions, got: #{rejected.map(&:inspect).join(", ")}") if rejected.size.positive?
    end

    # Validate against `actions` rule if argument is a Enumerable. otherwise, validate against `action` rule.
    #
    # @param unchecked the `actions` or `action` to be validated
    def validate_action_or_actions(unchecked)
      unchecked.is_a?(Enumerable) ? validate_actions(unchecked) : validate_action(unchecked)
    end

    # Validate `format` must be a Symbol and a valid MIME type
    #
    # @param unchecked the `format` to be validated
    def validate_format(unchecked)
      return TypeError.new("format must be a Symbol") unless unchecked.is_a?(Symbol)

      NameError.new("invalid format, got: #{unchecked.inspect}") unless supported_format?(unchecked)
    end

    # Validate `formats` must be an collection of Symbol which each of them is a valid MIME type
    #
    # @param unchecked the `formats` to be validated
    def validate_formats(unchecked)
      return TypeError.new("formats must not be empty") if unchecked.empty?

      rejected = unchecked.to_set.reject { |format| supported_format?(format) }

      NameError.new("invalid formats, got: #{rejected.map(&:inspect).join(", ")}") if rejected.size.positive?
    end

    # Validate against `formats` rule if argument is a Enumerable. otherwise, validate against `format` rule.
    #
    # @param unchecked the `formats` or `format` to be validated
    def validate_format_or_formats(unchecked)
      unchecked.is_a?(Enumerable) ? validate_formats(unchecked) : validate_format(unchecked)
    end

    # Validate `klazz` must be a Class/Module or a String referencing a Class/Module
    #
    # @param unchecked the `klazz` to be validated
    def validate_klazz(unchecked)
      return if unchecked.is_a?(Module) || unchecked.is_a?(String)

      TypeError.new("#{unchecked.inspect} must be a Class/Module or a String referencing a Class/Module")
    end

    # Validate `callable` must be a Symbol or Proc, a lambda must not require more than `max_arguments`
    #
    # @param unchecked the `callable` to be validated
    # @param max_arguments the arguments the `callable` is called with
    def validate_callable(unchecked, max_arguments = 0)
      unless unchecked.is_a?(Proc) || unchecked.is_a?(Symbol)
        return TypeError.new("#{unchecked.inspect} must be a Symbol or Proc")
      end
      return unless unchecked.is_a?(Proc) && unchecked.lambda?

      required = unchecked.parameters.count { |type, _| type == :req }
      return if required <= max_arguments

      requirement = max_arguments.zero? ? "arguments" : "more than #{max_arguments} argument"
      ArgumentError.new("#{unchecked.inspect} must not require #{requirement}")
    end

    def supported_format?(format)
      return Mime::SET.symbols.include?(format) if ActionPack.version < Gem::Version.new("7.1")

      Mime.symbols.include?(format)
    end
    private_class_method :supported_format?
  end
end
