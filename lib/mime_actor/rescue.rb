# frozen_string_literal: true

# :markup: markdown

require "mime_actor/dispatcher"
require "mime_actor/validator"

require "active_support/concern"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module MimeActor
  # # MimeActor Rescue
  #
  # Simillar to `ActionController::Rescue` but with additional filtering logic on `action`/`format`.
  #
  # @example Rescue RuntimeError when raised for any action with `json` format
  #   rescue_act_from RuntimeError, format: :json, with: :handle_json_error
  #
  module Rescue
    extend ActiveSupport::Concern

    include Validator

    included do
      mattr_accessor :actor_rescuers, instance_writer: false, default: []
    end

    module ClassMethods
      # Registers a rescue handler for the given error classes with `action`/`format` filter
      #
      # @param klazzes the error classes to rescue
      # @param action the `action` filter
      # @param format the `format` filter
      # @param with the rescue handler when `block` is not provided
      # @param block the `block` to evaluate when `with` is not provided
      #
      # @example Rescue StandardError when raised for any action with `html` format
      #   rescue_act_from StandardError, format: :html, with: :handle_html_error
      #
      # @example Rescue StandardError when raised for `show` action with `json` format
      #   rescue_act_from StandardError, format: :json, action: :show do |ex|
      #     render status: :bad_request, json: { error: ex.message }
      #   end
      #
      def rescue_act_from(*klazzes, action: nil, format: nil, with: nil, &block)
        raise ArgumentError, "error filter is required" if klazzes.empty?
        raise ArgumentError, "provide either with: or a block" unless with.present? ^ block_given?

        validate!(:callable, with) if with.present?
        with = block if block_given?

        validate!(:action_or_actions, action) if action.present?
        validate!(:format_or_formats, format) if format.present?

        klazzes.each do |klazz|
          validate!(:klazz, klazz)
          error = klazz.is_a?(Module) ? klazz.name : klazz

          # append at the end because strategies are read in reverse.
          actor_rescuers << [error, format, action, with]
        end
      end
    end

    # Resolve the error provided with the registered handlers.
    #
    # The handled error will be returned to indicate successful handling.
    #
    # @param error the error instance to rescue
    # @param action the `action` filter
    # @param format the `format` filter
    # @param visited the errors to skip after no rescue handler matched the filter
    #
    def rescue_actor(error, action:, format:, visited: [])
      return if visited.include?(error)

      visited << error
      rescuer = find_rescuer(error, format:, action:)
      if (dispatch = MimeActor::Dispatcher.build(rescuer, error, format, action))
        dispatch.call(self)
        error
      elsif error&.cause
        rescue_actor(error.cause, format:, action:, visited:)
      end
    end

    private

    def find_rescuer(error, format:, action:)
      return unless error

      *_, rescuer = actor_rescuers.reverse_each.detect do |rescuee, format_filter, action_filter|
        next if action_filter.present? && !Array.wrap(action_filter).include?(action)
        next if format_filter.present? && !Array.wrap(format_filter).include?(format)
        next unless (klazz = constantize_rescuee(rescuee))

        error.is_a?(klazz)
      end
      rescuer
    end

    def constantize_rescuee(class_or_name)
      case class_or_name
      when String, Symbol
        begin
          const_get(class_or_name)
        rescue NameError
          class_or_name.safe_constantize
        end
      else
        class_or_name
      end
    end
  end
end
