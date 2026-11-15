# frozen_string_literal: true

# :markup: markdown

require "mime_actor/callbacks"
require "mime_actor/dispatcher"
require "mime_actor/rescue"

require "active_support/concern"
require "active_support/notifications"

module MimeActor
  # # MimeActor Stage
  #
  # Stage plays an act: runs the `actor` within the act callbacks, rescues errors with the act rescue handlers.
  #
  # Each act is instrumented as `act.mime_actor` with the `controller`, `action` and `format` in the payload.
  #
  module Stage
    extend ActiveSupport::Concern

    include Callbacks
    include Rescue

    private

    # Calls the `actor` and passing arguments to it.
    #
    # NOTE: method call on actor if it is String or Symbol. Proc#call if actor is Proc
    #
    # @param actor either a method name or a Proc to evaluate
    # @param args arguments to be passed when calling the actor
    #
    def cue_actor(actor, *args, action:, format:)
      dispatcher = MimeActor::Dispatcher.build(actor, *args)
      raise TypeError, "invalid actor, got: #{actor.inspect}" unless dispatcher

      payload = { controller: self.class.name, action: action, format: format }
      ActiveSupport::Notifications.instrument("act.mime_actor", payload) do
        run_act_callbacks(action: action, format: format) { dispatcher.call(self) }
      rescue StandardError => e
        # the act is played again for the rescue handler, after the act callbacks are unwound
        play_act(action, format) { rescue_actor(e, action: action, format: format) } || raise
      end
    end
  end
end
