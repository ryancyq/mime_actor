# frozen_string_literal: true

# :markup: markdown

require "mime_actor/callbacks"
require "mime_actor/logging"
require "mime_actor/scene"
require "mime_actor/stage"

require "active_support/concern"
require "active_support/core_ext/object/blank"
require "active_support/lazy_load_hooks"
require "abstract_controller/rendering"
require "action_controller/metal/mime_responds"

module MimeActor
  # # MimeActor Action
  #
  # `Action` is the recommended `Module` to be included in the `ActionController`.
  #
  # Provides intuitive way of `action` rendering for a specific MIME type with rescue handlers.
  #
  module Action
    extend ActiveSupport::Concern

    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Callbacks
    include Scene
    include Stage
    include Logging

    # The core logic where rendering logics are collected as `Proc` and passed over to `ActionController::MimeResponds`
    #
    # @param action the `action` of the controller
    #
    # @example process `create` action
    #   start_scene(:create)
    #
    #   # it is equivalent to the following if `create` action is configured with `html` and `json` formats
    #   def create
    #     respond_to |format|
    #       format.html { public_send(:create_html) }
    #       format.json { public_send(:create_json) }
    #     end
    #   end
    #
    def start_scene(action)
      formats = acting_scenes.fetch(action, {})

      if formats.empty?
        logger.warn { "format is empty for action: #{action.inspect}" }
        return
      end

      respond_to do |collector|
        formats.each do |format, actor|
          dispatch = lambda do
            run_act_callbacks(format) do
              cue_actor(actor.presence || "#{action}_#{format}", action:, format:)
            end
          end
          collector.public_send(format, &dispatch)
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
