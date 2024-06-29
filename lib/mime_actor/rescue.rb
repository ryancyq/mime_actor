# frozen_string_literal: true

# :markup: markdown

require "mime_actor/stage"
require "mime_actor/validator"

require "active_support/concern"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/string/inflections"

module MimeActor
  # # MimeActor Rescue
  #
  # Simillar to ActionController::Rescue but with additional filtering logic on Action/Format.
  #
  module Rescue
    extend ActiveSupport::Concern

    include Stage
    include Validator

    included do
      mattr_accessor :actor_rescuers, instance_writer: false, default: []
    end

    module ClassMethods
      ##
      # Registers a rescue handler for the given error classes with action/format filter
      #
      # rescue_actor_from StandardError, format: :json, action: :show do |ex|
      #   render status: :bad_request, json: { error: ex.message }
      # end
      #
      # rescue_actor_from StandardError, format: :html, with: :handle_html_error
      #
      def rescue_actor_from(*klazzes, action: nil, format: nil, with: nil, &block)
        raise ArgumentError, "error filter is required" if klazzes.empty?

        validate!(:with, with, block)
        with = block if block_given?

        if action.present?
          if action.is_a?(Enumerable)
            validate!(:actions, action)
          else
            validate!(:action, action)
          end
        end

        if format.present?
          if format.is_a?(Enumerable)
            validate!(:formats, format)
          else
            validate!(:format, format)
          end
        end

        klazzes.each do |klazz|
          error = case klazz
                  when Module
                    klazz.name
                  when String
                    klazz
                  else
                    message = "#{klazz.inspect} must be a Class/Module or a String referencing a Class/Module"
                    raise ArgumentError, message
                  end

          # append at the end because strategies are read in reverse.
          actor_rescuers << [error, format, action, with]
        end
      end

      ##
      # Resolve the error provided with the registered handlers.
      # The handled error will be returned to indicate successful handling
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
          case rescuer_method.arity
          when 0
            ->(_e, _f, _a) { rescuer_method.call }
          when 1
            ->(e, _f, _a) { rescuer_method.call(e) }
          when 2
            ->(e, f, _a) { rescuer_method.call(e, f) }
          else
            ->(e, f, a) { rescuer_method.call(e, f, a) }
          end
        when Proc
          case rescuer.arity
          when 0
            ->(_e, _f, _a) { context.instance_exec(&rescuer) }
          when 1
            ->(e, _f, _a) { context.instance_exec(e, &rescuer) }
          when 2
            ->(e, f, _a) { context.instance_exec(e, f, &rescuer) }
          else
            ->(e, f, a) { context.instance_exec(e, f, a, &rescuer) }
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
  end
end
