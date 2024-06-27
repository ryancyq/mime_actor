# frozen_string_literal: true

require "mime_actor/scene"
require "mime_actor/stage"
require "mime_actor/rescue"

require "active_support/concern"
require "abstract_controller/rendering"
require "action_controller/metal/mime_responds"

module MimeActor
  module Act
    extend ActiveSupport::Concern

    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    include Scene
    include Stage
    include Rescue
    include Logging

    def start_scene(action)
      action = action&.to_sym
      formats = acting_scenes.fetch(action, Set.new)

      if formats.empty?
        logger.warn { "format is empty, action: #{action}" }
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
  end
end
