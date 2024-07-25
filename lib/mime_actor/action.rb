# frozen_string_literal: true

# :markup: markdown

require "mime_actor/logging"
require "mime_actor/scene"
require "mime_actor/stage"

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/object/blank"
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

    included do
      mattr_accessor :actor_delegator, instance_writer: false, default: ->(action, format) { "#{action}_#{format}" }
    end

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
    def start_scene
      action = action_name.to_sym
      formats = acting_scenes.fetch(action, {})

      if formats.empty?
        logger.warn { "format is empty for action: #{action_name.inspect}" }
        return
      end

      respond_to do |collector|
        formats.each do |format, actor|
          callable = actor.presence || actor_delegator.call(action, format)
          dispatch = -> { cue_actor(callable, format:) }
          collector.public_send(format, &dispatch)
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
