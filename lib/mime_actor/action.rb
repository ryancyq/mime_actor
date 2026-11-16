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

    # Routes declared actions to the scene, see `AbstractController::Base#method_for_action`.
    def method_for_action(action_name)
      self.class.acting_scenes.key?(action_name.to_sym) ? "play_scene" : super
    end

    # Responds to each declared format of the action with its act.
    def play_scene(*args)
      action = action_name.to_sym
      respond_to do |collector|
        self.class.acting_scenes.fetch(action).each do |format, actor|
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
