# frozen_string_literal: true

# :markup: markdown

require "mime_actor/logging"
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
    include Logging

    # The core logic where rendering logics are collected as `Proc` and passed over to `ActionController::MimeResponds`
    #
    # @example process `create` action
    #   # it uses AbstractController#action_name to process
    #   start_scene
    #
    #   # it is equivalent to the following if `create` action is configured with `html` and `json` formats
    #   def create
    #     respond_to |format|
    #       format.html { public_send(:create_html) }
    #       format.json { public_send(:create_json) }
    #     end
    #   end
    #
    def start_scene(&block)
      action = action_name.to_sym
      formats = acting_scenes.fetch(action, {})
      return respond_to_scene(action, formats, block) unless formats.empty?

      logger.warn { "no format found for action: #{action_name.inspect}" }
      yield if block_given?
    end

    private

    def respond_to_scene(action, formats, block)
      respond_to do |collector|
        formats.each do |format, actor|
          callable = actor.presence || block
          dispatch = -> { cue_actor(callable, action, format, format:) }
          collector.public_send(format, &dispatch)
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
