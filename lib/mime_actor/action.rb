# frozen_string_literal: true

require "mime_actor/scene"
require "mime_actor/stage"
require "mime_actor/rescue"

require "active_support/concern"
require "active_support/lazy_load_hooks"
require "abstract_controller/rendering"
require "action_controller/metal/mime_responds"

module MimeActor
  # # MimeActor Action
  #
  # Action is the recommended Module to be included in ActionController.
  #
  # Provides intuitive way of action rendering for a specific MIME type with rescue handlers.
  #
  module Action
    extend ActiveSupport::Concern

    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Scene
    include Stage
    include Rescue
    include Logging

    ##
    # The core logic where rendering logics are collected as Proc through configuration and passed over to ActionController::MimeResponds
    def start_scene(action)
      action = action&.to_sym
      formats = acting_scenes.fetch(action, Set.new)

      if formats.empty?
        logger.warn { "format is empty for action :#{action}" }
        return
      end

      respond_to do |collector|
        formats.each do |format|
          dispatch = self.class.dispatch_cue(action: action, format: format, context: self) do
            cue_actor("#{action}_#{format}")
          end
          collector.public_send(format, &dispatch)
        end
      end
    end

    ActiveSupport.run_load_hooks(:mime_actor, self)
  end
end
