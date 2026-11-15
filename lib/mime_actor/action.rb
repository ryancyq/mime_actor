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

    # The core logic where the acts of an `action` are collected and passed over to `ActionController::MimeResponds`.
    # It runs once per request, regardless of how many classes in the hierarchy declared the `action`.
    #
    # @example `create` action configured with `html` and `json` formats
    #   act_on_action :create, format: %i[html json]
    #
    #   # dispatching `create` is equivalent to
    #   respond_to do |format|
    #     format.html { create }
    #     format.json { create }
    #   end
    #
    # NOTE: `ActionController::BasicImplicitRender` is replaced, the default render runs after the act
    # so that the act callbacks run before it.
    def send_action(method_name, *args)
      action = method_name.to_sym
      formats = acting_scenes[action]
      return super if formats.nil?

      respond_to do |collector|
        formats.each do |format, actor|
          collector.public_send(format) do
            if actor
              cue_actor(actor, action, format, action: action, format: format)
            else
              cue_actor(method_name, *args, action: action, format: format)
            end
            default_render if !performed? && respond_to?(:default_render, true)
          end
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
