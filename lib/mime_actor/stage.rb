# frozen_string_literal: true

# :markup: markdown

require "mime_actor/callbacks"
require "mime_actor/dispatcher"
require "mime_actor/logging"
require "mime_actor/rescue"

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  # # MimeActor Stage
  #
  # Stage provides helper methods for actor lookup and invocation.
  #
  module Stage
    extend ActiveSupport::Concern

    include Callbacks
    include Rescue
    include Logging

    included do
      mattr_accessor :raise_on_actor_error, instance_writer: false, default: false
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
      #   dispatch = self.class.dispatch_act(action: :create, format: :json, context: self) do
      #       puts "completed the dispatch"
      #   end
      #
      #   dispatch.call == "completed the dispatch" # true
      #
      def dispatch_act(action: nil, format: nil, context: self, &block)
        raise ArgumentError, "block must be provided" unless block_given?

        lambda do
          context.instance_exec(&block)
        rescue StandardError => e
          (respond_to?(:rescue_actor) && rescue_actor(e, action:, format:, context:)) || raise
        end
      end

      # TODO: remove on next breaking change release
      alias dispatch_cue dispatch_act
    end

    # Calls the `actor` and passing arguments to it.
    # If a block is given, the result from the `actor` method will be yieled to the block.
    #
    # NOTE: method call on actor if it is String or Symbol. Proc#call if actor is Proc
    #
    # @param actor either a method name or a Proc to evaluate
    # @param args arguments to be passed when calling the actor
    #
    def cue_actor(actor, *args, format:)
      dispatcher = MimeActor::Dispatcher.build(actor, *args)
      raise TypeError, "invalid actor, got: #{actor.inspect}" unless dispatcher

      run_act_callbacks(format) do
        result = dispatcher.call(self)
        block_given? ? yield(result) : result
      end
    rescue MimeActor::ActorNotFound => e
      logger.error { "actor error, cause: #{e.inspect}" } unless raise_on_actor_error
      raise e if raise_on_actor_error
    rescue StandardError => e
      rescued = rescue_actor(e, action: action_name.to_sym, format: format)
      rescued || raise
    end
  end
end
