# frozen_string_literal: true

# :markup: markdown

require "mime_actor/dispatcher"
require "mime_actor/validator"
require "mime_actor/stage"

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

    include Stage
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
        raise ArgumentError, "provide either the with: argument or a block" unless with.present? ^ block_given?

        if block_given?
          with = block
        else
          validate!(:with, with)
        end

        if action.present?
          action.is_a?(Enumerable) ? validate!(:actions, action) : validate!(:action, action)
        end

        if format.present?
          format.is_a?(Enumerable) ? validate!(:formats, format) : validate!(:format, format)
        end

        klazzes.each do |klazz|
          validate!(:klazz, klazz)
          error = klazz.is_a?(Module) ? klazz.name : klazz

          # append at the end because strategies are read in reverse.
          actor_rescuers << [error, format, action, with]
        end
      end

      # Resolve the error provided with the registered handlers.
      #
      # The handled error will be returned to indicate successful handling.
      #
      # @param error the error instance to rescue
      # @param action the `action` filter
      # @param format the `format` filter
      # @param context the context to evaluate for rescue handler
      # @param visited the errors to skip after no rescue handler matched the filter
      #
      def rescue_actor(error, action: nil, format: nil, context: self, visited: [])
        return if visited.include?(error)

        visited << error
        if (rescuer = dispatch_rescuer(error, format:, action:, context:))
          rescuer.call(error, format, action)
          error
        elsif error&.cause
          rescue_actor(error.cause, format:, action:, context:, visited:)
        end
      end

      private

      def dispatch_rescuer(error, format:, action:, context:)
        case rescuer = find_rescuer(error, format:, action:)
        when Symbol
          rescuer_method = context.method(rescuer)
          lambda do |*args|
            passable_args = rescuer_method.arity.negative? ? args : args.take(rescuer_method.arity)
            rescuer_method.call(*passable_args)
          end
        when Proc
          lambda do |*args|
            passable_args = rescuer.arity.negative? ? args : args.take(rescuer.arity)
            context.instance_exec(*passable_args, &rescuer)
          end
        end
      end

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
        dispatched = false
        result = catch(:abort) do
          dispatch.to_callable.call(self).tap { dispatched = true }
        end
        logger.error { "rescue error, cause: #{result.inspect}" } unless dispatched
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
