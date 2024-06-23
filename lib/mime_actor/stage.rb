# frozen_string_literal: true

require 'mime_actor/errors'

require 'active_support/concern'
require 'active_support/configurable'
require "active_support/core_ext/module/attribute_accessors"
require 'abstract_controller/logger'

module MimeActor
  module Stage
    extend ActiveSupport::Concern

    include ActiveSupport::Configurable
    include AbstractController::Logger

    included do
      mattr_accessor :raise_on_missing_actor, instance_writer: false, default: false
    end
    
    def find_actor(actor_name)
      if self.respond_to?(:action_methods)
        return self.method(actor_name) if public_send(:action_methods).include?(actor_name)
      elsif self.methods.include?(actor_name)
        return self.method(actor_name)
      end

      error = MimeActor::ActorNotFound.new(actor_name) 
      unless self.raise_on_missing_actor
        logger.warn { "Actor not found: #{error.inspect}" }
        return
      end

      raise error
    end
  end
end