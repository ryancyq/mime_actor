# frozen_string_literal: true

require "mime_actor/errors"

require "active_support/concern"
require "active_support/configurable"
require "active_support/core_ext/module/attribute_accessors"
require "set" # required by mime_type with ruby <= 3.1
require "action_dispatch/http/mime_type"
require "abstract_controller/logger"

module MimeActor
  module Stage
    extend ActiveSupport::Concern

    include ActiveSupport::Configurable
    include AbstractController::Logger

    included do
      mattr_accessor :raise_on_missing_actor, instance_writer: false, default: false
      mattr_accessor :stage_formats, instance_writer: false, default: Mime::SET.symbols.to_set
    end

    module ClassMethods
      def actor?(actor_name)
        return action_methods.include?(actor_name.to_s) if singleton_methods.include?(:action_methods)

        instance_methods.include?(actor_name.to_sym)
      end
    end

    def actor?(actor_name)
      return action_methods.include?(actor_name.to_s) if respond_to?(:action_methods)

      methods.include?(actor_name.to_sym)
    end

    def find_actor(actor_name)
      return method(actor_name) if actor?(actor_name)

      error = MimeActor::ActorNotFound.new(actor_name)
      raise error if raise_on_missing_actor

      logger.warn { "Actor not found: #{error.inspect}" }
    end

    def cue_actor(actor_name, *args)
      return unless actor?(actor_name)

      result = public_send(actor_name, *args)
      if block_given?
        yield result
      else
        result
      end
    end
  end
end
