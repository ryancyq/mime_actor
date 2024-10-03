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

    # Calls the `actor` and passing arguments to it.
    # If a block is given, the result from the `actor` method will be yieled to the block.
    #
    # NOTE: method call on actor if it is String or Symbol. Proc#call if actor is Proc
    #
    # @param actor either a method name or a Proc to evaluate
    # @param args arguments to be passed when calling the actor
    #
    def cue_actor(actor, *args, action:, format:)
      dispatcher = MimeActor::Dispatcher.build(actor, *args)
      raise TypeError, "invalid actor, got: #{actor.inspect}" unless dispatcher

      self.class.validate!(:format, format)

      run_act_callbacks(action: action, format: format) do
        result = dispatcher.call(self)
        block_given? ? yield(result) : result
      end
    rescue MimeActor::ActorNotFound => e
      logger.error { "actor error, cause: #{e.inspect}" } unless raise_on_actor_error
      raise e if raise_on_actor_error
    rescue StandardError => e
      rescued = rescue_actor(e, action: action, format: format)
      rescued || raise
    end
  end
end
