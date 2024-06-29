# frozen_string_literal: true

# :markup: markdown

require "active_support/concern"
require "set" # required by mime_type with ruby <= 3.1
require "action_dispatch/http/mime_type"

module MimeActor
  # # MimeActor Validator
  #
  # Validator provides validation rules for `action`, `format`, and `with` handlers by default.
  #
  #     # raise error when rule is violated
  #     validate!(:action, action_param)
  #     
  #     # return the error when rule is violated
  #     ex = validate_action(action_param)
  #     raise ex if error
  #
  module Validator
    extend ActiveSupport::Concern

    included do
      mattr_accessor :scene_formats, instance_writer: false, default: Mime::SET.symbols.to_set
    end

    module ClassMethods
      ##
      # Raise the error returned by validator if any.
      def validate!(rule, *args)
        validator = "validate_#{rule}"
        raise NameError, "Validator not found, got: #{validator}" unless respond_to?(validator, true)

        error = send(validator, *args)
        raise error if error
      end

      ##
      # validate `action` must be a Symbol
      def validate_action(unchecked)
        ArgumentError.new("action must be a Symbol") unless unchecked.is_a?(Symbol)
      end

      ##
      # validate `actions` must be a collection of Symbol
      def validate_actions(unchecked)
        rejected = unchecked.reject { |action| action.is_a?(Symbol) }
        NameError.new("invalid actions, got: #{rejected.join(", ")}") if rejected.size.positive?
      end

      ##
      # validate `format` must be a Symbol and a valid MIME type
      def validate_format(unchecked)
        return ArgumentError.new("format must be a Symbol") unless unchecked.is_a?(Symbol)

        NameError.new("invalid format, got: #{unchecked}") unless scene_formats.include?(unchecked)
      end

      ##
      # validate `formats` must be an collection of Symbol which each of them is a valid MIME type
      def validate_formats(unchecked)
        unfiltered = unchecked.to_set
        filtered = unfiltered & scene_formats
        rejected = unfiltered - filtered

        NameError.new("invalid formats, got: #{rejected.join(", ")}") if rejected.size.positive?
      end

      ##
      # validate `with` or `block` must be provided and if `with` is provided, it must be a Symbol or Proc
      def validate_with(unchecked, block)
        if unchecked.present? && block.present?
          return ArgumentError.new("provide either the with: keyword argument or a block")
        end
        unless unchecked.present? || block.present?
          return ArgumentError.new("provide the with: keyword argument or a block")
        end

        return if block.present?
        return if unchecked.is_a?(Proc) || unchecked.is_a?(Symbol)

        ArgumentError.new("with handler must be a Symbol or Proc, got: #{unchecked.inspect}")
      end
    end
  end
end
