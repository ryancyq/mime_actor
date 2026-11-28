# frozen_string_literal: true

# :markup: markdown

require "mime_actor/callbacks"
require "mime_actor/errors"
require "mime_actor/rescue"
require "mime_actor/scene"

require "active_support/concern"
require "active_support/lazy_load_hooks"
require "active_support/notifications"
require "abstract_controller/rendering"
require "action_controller/metal/mime_responds"

module MimeActor
  # # MimeActor Action
  #
  # `Action` is the `Module` to be included in the `ActionController`.
  #
  # Provides intuitive way of `action` processing for a specific MIME type with callback + rescue handlers.
  #
  # Each act is instrumented as `act.mime_actor` with the `controller`, `action` and `format` in the payload.
  #
  module Action
    extend ActiveSupport::Concern

    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Scene
    include Callbacks
    include Rescue

    Act = Struct.new(:action, :format)

    private

    # The `action` of the act being played, `nil` outside of an act.
    def act_action
      @mime_actor_act&.action
    end

    # The `format` of the act being played, `nil` outside of an act.
    def act_format
      @mime_actor_act&.format
    end

    def method_for_action(action_name)
      # an action hidden by a subclass must stay hidden
      return super unless action_method?(action_name) && self.class.acting_scenes.key?(action_name.to_sym)

      "play_scene"
    end

    def play_scene(*args)
      action = action_name.to_sym
      respond_to do |collector|
        self.class.acting_scenes.fetch(action).each do |format, actor|
          collector.public_send(format) { play_act(action, format, actor, *args) }
        end
      end
    end

    def play_act(action, format, actor, *args)
      @mime_actor_act = Act.new(action, format)
      payload = { controller: self.class.name, action: action, format: format }
      ActiveSupport::Notifications.instrument("act.mime_actor", payload) do
        run_callbacks(:act) { actor ? call_actor(actor) : send(action, *args) }
      rescue StandardError => e
        rescue_act(e) || raise
      end
    ensure
      @mime_actor_act = nil
    end

    def call_actor(actor)
      return instance_exec(&actor) if actor.is_a?(Proc)
      raise MimeActor::ActorNotFound, actor unless respond_to?(actor, true)

      send(actor)
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
