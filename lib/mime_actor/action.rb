# frozen_string_literal: true

# :markup: markdown

require "mime_actor/callbacks"
require "mime_actor/errors"
require "mime_actor/rescue"
require "mime_actor/scene"

require "active_support/concern"
require "active_support/lazy_load_hooks"
require "active_support/notifications"
require "abstract_controller/callbacks"
require "abstract_controller/rendering"
require "action_controller/metal/exceptions"
require "action_controller/metal/mime_responds"

module MimeActor
  # # MimeActor Action
  #
  # `Action` is the `Module` to be included in the `ActionController`.
  #
  # Provides intuitive way of `action` processing for a specific MIME type with callback + rescue handlers.
  #
  # The act format is negotiated by `before_action :negotiate_act_format`, added where `Action` is included.
  #
  # Each act is instrumented as `act.mime_actor` with the `controller`, `action` and `format` in the payload.
  #
  module Action
    extend ActiveSupport::Concern

    include AbstractController::Callbacks # required by before_action
    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Scene
    include Callbacks
    include Rescue

    Act = Struct.new(:action, :format)

    included do
      before_action :negotiate_act_format
    end

    def view_assigns
      super.tap { |assigns| assigns.delete("mime_actor_act") }
    end

    private

    # The `action` of the act, `nil` until the act format is negotiated.
    def act_action
      @mime_actor_act&.action
    end

    # The `format` of the act, `nil` until the act format is negotiated.
    def act_format
      @mime_actor_act&.format
    end

    # the act belongs to a single request
    def process_action(*)
      @mime_actor_act = nil
      super
    end

    # Picks the `format` of a declared `action` from the request, raises `ActionController::UnknownFormat` if none.
    def negotiate_act_format
      return if @mime_actor_act

      action = action_name.to_sym
      return unless (scenes = self.class.acting_scenes[action])

      verify_scene!(action)
      mime = request.negotiate_mime(scenes.keys.map { |format| Mime[format] })
      raise ActionController::UnknownFormat unless mime

      @mime_actor_act = Act.new(action, mime.to_sym)
    end

    def method_for_action(action_name)
      # an action hidden by a subclass must stay hidden
      return super unless action_method?(action_name) && self.class.acting_scenes.key?(action_name.to_sym)

      "play_scene"
    end

    def play_scene(*args)
      negotiate_act_format # when the before_action is skipped
      actor = self.class.acting_scenes.fetch(act_action).fetch(act_format)
      respond_to do |collector|
        collector.public_send(act_format) { play_act(actor, *args) }
      end
    end

    def play_act(actor, *args)
      payload = { controller: self.class.name, action: act_action, format: act_format }
      ActiveSupport::Notifications.instrument("act.mime_actor", payload) do
        run_callbacks(:act) { actor ? call_actor(actor) : send(act_action, *args) }
      rescue StandardError => e
        rescue_act(e) || raise
      end
    end

    def call_actor(actor)
      actor.is_a?(Proc) ? instance_exec(&actor) : send(actor)
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
