# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/configurable'
require "active_support/core_ext/module/attribute_accessors"
require 'abstract_controller/logger'

module MimeActor
  module Rescuer
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable
    include AbstractController::Logger

    included do
      mattr_accessor :actor_rescuers, instance_writer: false, default: []
    end

    module ClassMethods
      def rescue_act_from(*klazzes, format: nil, action: nil, with: nil, &block)
        unless with
          raise ArgumentError, "Provide the with: keyword argument or a block" unless block_given?
          with = block
        end
        raise ArgumentError, "Rescue handler can only be Symbol/Proc" unless with.is_a?(Proc) || with.is_a?(Symbol)

        if format.present?
          case format
          when Symbol
            raise ArgumentError, "Unsupported format: #{format}" unless SUPPORTED_MIME_TYPES.include?(format.to_sym)
          when Enumerable
            unfiltered = format.to_set
            filtered = unfiltered & SUPPORTED_MIME_TYPES
            rejected = unfiltered - filtered
            raise ArgumentError, "Unsupported formats: #{rejected.join(', ')}" if rejected.size.positive?
          else
            raise ArgumentError, "Format filter can only be Symbol/Enumerable"
          end
        end

        if action.present?
          message = "Action filter can only be Symbol/Enumerable"
          raise ArgumentError, message unless action.is_a?(Symbol) || action.is_a?(Enumerable)
        end

        klazzes.each do |klazz|
          error = if klazz.is_a?(Module)
            klazz.name
          elsif klazz.is_a?(String)
            klazz
          else
            raise ArgumentError, "#{klazz.inspect} must be a class/module or a String referencing a class/module"
          end

          # append at the end because strategies are read in reverse.
          self.actor_rescuers << [error, format, action, with]
        end
      end

      def dispatch_act(action: nil, format: nil, context: self, &block)
        lambda do
          case block
          when Proc
            context.instance_exec(&block)
          else
            block.call
          end
        rescue Exception => ex
          rescue_actor(ex, format:, action:, context:) || raise
        end
      end

      def rescue_actor(error, action: nil, format: nil, context: self, visited: [])
        visited << error

        if rescuer = dispatch_rescuer(error, format:, action:, context:)
          rescuer.call(error, format, action)
          error
        elsif error && error.cause && !visited.include?(error.cause)
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
            -> e,f,a { rescuer_method.call }
          when 1
            -> e,f,a { rescuer_method.call(e) }
          when 2
            -> e,f,a { rescuer_method.call(e,f) }
          else
            -> e,f,a { rescuer_method.call(e,f,a) }
          end
        when Proc
          case rescuer.arity
          when 0
            -> e,f,a { context.instance_exec(&rescuer) }
          when 1
            -> e,f,a { context.instance_exec(e, &rescuer) }
          when 2
            -> e,f,a { context.instance_exec(e, f, &rescuer) }
          else
            -> e,f,a { context.instance_exec(e, f, a, &rescuer) }
          end
        end
      end

      def find_rescuer(error, format:, action:)
        return unless error

        *_, rescuer = actor_rescuers.reverse_each.detect do |rescuee, format_filter, action_filter|
          next if action_filter.present? && !Array.wrap(action_filter).include?(action)
          next if format_filter.present? && !Array.wrap(format_filter).include?(format)
          next unless klazz = constantize_rescuee(rescuee)

          klazz === error # klazz is a member of error
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