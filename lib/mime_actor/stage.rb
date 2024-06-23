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

    def actor?(actor_name)
      return self.public_send(:action_methods).include?(actor_name.to_s) if self.respond_to?(:action_methods)
      
      self.methods.include?(actor_name.to_sym)
    end
    
    def find_actor(actor_name)
      return self.method(actor_name) if actor?(actor_name)

      error = MimeActor::ActorNotFound.new(actor_name) 
      unless self.raise_on_missing_actor
        logger.warn { "Actor not found: #{error.inspect}" }
        return
      end

      raise error
    end
  end
end