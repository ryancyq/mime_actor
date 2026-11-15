# frozen_string_literal: true

# :markup: markdown

require "mime_actor/scene"
require "mime_actor/stage"

require "active_support/concern"
require "active_support/lazy_load_hooks"
require "abstract_controller/rendering"
require "action_controller/metal/mime_responds"

module MimeActor
  # # MimeActor Action
  #
  # `Action` is the recommended `Module` to be included in the `ActionController`.
  #
  # Provides intuitive way of `action` processing for a specific MIME type with callback + rescue handlers.
  #
  module Action
    extend ActiveSupport::Concern

    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Scene
    include Stage

    private

    # Routes the declared `action` to the scene, see `AbstractController::Base#method_for_action`.
    # Rails dispatches the scene once per request, regardless of how many classes in the hierarchy
    # declared the `action`, then renders by default if the scene did not.
    def method_for_action(action_name)
      acting_scenes.key?(action_name.to_sym) ? "_mime_actor_scene" : super
    end

    # The core logic where the acts of an `action` are collected and passed over to `ActionController::MimeResponds`.
    #
    # @example `create` action configured with `html` and `json` formats
    #   act_on_action :create, format: %i[html json]
    #
    #   # dispatching `create` is equivalent to
    #   respond_to do |format|
    #     format.html { create }
    #     format.json { create }
    #   end
    def _mime_actor_scene(*args)
      action = action_name.to_sym
      respond_to do |collector|
        acting_scenes.fetch(action).each do |format, actor|
          collector.public_send(format) do
            if actor
              cue_actor(actor, action, format, action: action, format: format)
            else
              cue_actor(action, *args, action: action, format: format)
            end
          end
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
