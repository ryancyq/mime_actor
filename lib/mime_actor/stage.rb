# frozen_string_literal: true

# :markup: markdown

require "mime_actor/errors"
require "mime_actor/logging"

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  # # MimeActor Stage
  #
  # Stage provides helper methods for actor lookup and invocation.
  #
  module Stage
    extend ActiveSupport::Concern

    include Logging

    included do
      mattr_accessor :raise_on_missing_actor, instance_writer: false, default: false
    end

    module ClassMethods
      # Determine if the `actor_name` belongs to a public instance method excluding methods inherited from ancestors
      #
      # @param actor_name
      #
      def actor?(actor_name)
        # exclude public methods from ancestors
        found = public_instance_methods(false).include?(actor_name.to_sym)
        # exclude private methods from ancestors
        if !found && private_instance_methods(false).include?(actor_name.to_sym)
          logger.debug { "actor must be public method, #{actor_name} is private method" }
        end
        found
      end

      # Wraps the given `block` with a `lambda`, rescue any error raised from the `block`.
      # Otherwise, error will be re-raised.
      #
      # @param action the `action` to be passed on to `rescue_actor`
      # @param format the `format` to be passed on to `rescue_actor`
      # @param context the context for the block evaluation
      # @param block the `block` to be evaluated
      #
      # @example Dispatch a cue that prints out a text
      #   dispatch = self.class.dispatch_cue(action: :create, format: :json, context: self) do
      #       puts "completed the dispatch"
      #   end
      #
      #   dispatch.call == "completed the dispatch" # true
      #
      def dispatch_cue(action: nil, format: nil, context: self, &block)
        raise ArgumentError, "block must be provided" unless block_given?

        lambda do
          context.instance_exec(&block)
        rescue StandardError => e
          (respond_to?(:rescue_actor) && rescue_actor(e, action:, format:, context:)) || raise
        end
      end
    end

    # Calls the `actor` and passing arguments to it.
    # If a block is given, the result from the `actor` method will be yieled to the block.
    #
    # NOTE: method call on actor if it is String or Symbol. Proc#call if actor is Proc
    #
    # @param actor either a method name or a block to evaluate
    def cue_actor(actor, *args)
      result = case actor
               when String, Symbol
                 actor_method_call(actor, *args)
               when Proc
                 actor_proc_call(actor, *args)
               else
                 raise ArgumentError, "invalid actor, got: #{actor.inspect}"
               end

      if block_given?
        yield result
      else
        result
      end
    end

    private

    def actor_method_call(actor_method, *args)
      unless self.class.actor?(actor_method)
        raise MimeActor::ActorNotFound, actor_method if raise_on_missing_actor

        logger.warn { "actor #{actor_method.inspect} not found" }
        return
      end

      public_send(actor_method, *args)
    end

    def actor_proc_call(actor_proc, *args)
      passable_args = actor_proc.arity.negative? ? args : args.take(actor_proc.arity)
      actor_proc.call(*passable_args)
    end
  end
end
