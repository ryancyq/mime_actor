# frozen_string_literal: true

require "mime_actor/errors"
require "mime_actor/stage"

require "active_support/concern"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module MimeActor
  module Rescue
    extend ActiveSupport::Concern

    include Stage

    included do
      mattr_accessor :actor_rescuers, instance_writer: false, default: []
    end

    module ClassMethods
      def rescue_actor_from(*klazzes, action: nil, format: nil, with: nil, &block)
        raise ArgumentError, "Error filter can't be empty" if klazzes.empty?
        raise ArgumentError, "Provide only the with: keyword argument or a block" if with.present? && block_given?
        raise ArgumentError, "Provide the with: keyword argument or a block" unless with.present? || block_given?

        with = block if block_given?
        raise ArgumentError, "Rescue handler can only be Symbol/Proc" unless with.is_a?(Proc) || with.is_a?(Symbol)

        if format.present?
          case format
          when Symbol
            raise MimeActor::FormatInvalid, format unless stage_formats.include?(format.to_sym)
          when Enumerable
            unfiltered = format.to_set
            filtered = unfiltered & stage_formats
            rejected = unfiltered - filtered
            raise MimeActor::FormatInvalid, rejected if rejected.size.positive?
          else
            raise MimeActor::FormatFilterInvalid
          end
        end

        if action.present?
          case action
          when Symbol, Enumerable
            raise MimeActor::ActionFilterInvalid if action.is_a?(Enumerable) && !action.reduce { |a| a.is_a?(Symbol) }
          else
            raise MimeActor::ActionFilterInvalid
          end
        end

        klazzes.each do |klazz|
          error = if klazz.is_a?(Module)
                    klazz.name
                  elsif klazz.is_a?(String)
                    klazz
                  else
                    raise ArgumentError,
                          "#{klazz.inspect} must be a class/module or a String referencing a class/module"
                  end

          # append at the end because strategies are read in reverse.
          actor_rescuers << [error, format, action, with]
        end
      end

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
