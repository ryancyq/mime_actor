# frozen_string_literal: true

require "mime_actor/errors"
require "mime_actor/logging"

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  module Stage
    extend ActiveSupport::Concern

    include Logging

    included do
      mattr_accessor :raise_on_missing_actor, instance_writer: false, default: false
    end

    module ClassMethods
      def actor?(actor_name)
        return action_methods.include?(actor_name.to_s) if singleton_methods.include?(:action_methods)

        instance_methods.include?(actor_name.to_sym)
      end

      def dispatch_cue(action: nil, format: nil, context: self, &block)
        lambda do
          context.instance_exec(&block)
        rescue StandardError => e
          (respond_to?(:rescue_actor) && rescue_actor(e, action:, format:, context:)) || raise
        end
      end
    end

    def actor?(actor_name)
      return action_methods.include?(actor_name.to_s) if respond_to?(:action_methods)

      methods.include?(actor_name.to_sym)
    end

    def cue_actor(actor_name, *args)
      unless self.class.actor?(actor_name)
        raise MimeActor::ActorNotFound, actor_name if raise_on_missing_actor

        logger.warn { "actor not found, got: #{actor_name}" }
        return
      end

      result = public_send(actor_name, *args)
      if block_given?
        yield result
      else
        result
      end
    end
  end
end
