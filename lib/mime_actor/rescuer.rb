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
          raise
        end
      end
    end
  end
end