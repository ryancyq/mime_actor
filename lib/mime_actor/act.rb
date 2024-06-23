# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/configurable'
require "active_support/core_ext/module/attribute_accessors"
require 'abstract_controller/logger'
require 'abstract_controller/rendering'
require 'action_controller/metal/mime_responds'

module MimeActor
  module Act
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable
    include AbstractController::Logger
    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds
    include Scene
    include Rescue

    included do
      mattr_accessor :raise_on_missing_actor, instance_writer: false, default: false
    end

    module ClassMethods
      def dispatch_act(action: nil, format: nil, context: self, &block)
        lambda do
          context.instance_exec(&block)
        rescue Exception => ex
          respond_to?(:rescue_actor) && public_send(:rescue_actor, ex, action:, format:, context:) || raise
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
          next unless actor = find_actor(action, mime_type)

          dispatch = self.class.dispatch_act(
            action: action, 
            format: mime_type,
            context: self,
            &actor
          )
          collector.public_send(mime_type, &dispatch)
        end
      end
    end

    def find_actor(action, mime_type)
      actor_name = "#{action}_#{mime_type}"
      
      if respond_to?(:action_methods) && public_send(:action_methods).include?(actor_name)
        return self.method(actor_name)
      end

      error = MimeActor::ActorNotFound.new(action, mime_type) 
      unless self.raise_on_missing_actor
        logger.warn { "Actor not found: #{error.inspect}" }
        return
      end

      raise error
    end
  end
end