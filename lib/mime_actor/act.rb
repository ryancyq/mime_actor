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

    module ClassMethods
      def dispatch_act(action: nil, format: nil, context: self, &block)
        lambda do
          context.instance_exec(&block)
        rescue StandardError => e
          (respond_to?(:rescue_actor) && rescue_actor(e, action:, format:, context:)) || raise
        end
      end
    end

    private

    def play_scene(action)
      action = action&.to_sym
      return unless acting_scenes.key?(action)

      mime_types = acting_scenes.fetch(action, Set.new)
      respond_to do |collector|
        mime_types.each do |mime_type|
          next unless (actor = find_actor("#{action}_#{mime_type}"))

          dispatch = self.class.dispatch_act(
            action:  action,
            format:  mime_type,
            context: self,
            &actor
          )
          collector.public_send(mime_type, &dispatch)
        end
      end
    end
  end
end
