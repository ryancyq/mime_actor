# frozen_string_literal: true

# :markup: markdown

require "set"

module MimeActor
  class Error < StandardError
    def inspect
      "<#{self.class.name}> #{message}"
    end

    def generate_message
      self.class.name
    end
  end

  class ActorError < Error
    attr_reader :actor

    def initialize(actor)
      @actor = actor
      super(generate_message)
    end
  end

  class ActorNotFound < ActorError
    def generate_message
      "#{actor.inspect} not found"
    end
  end

  class ActionError < Error
    attr_reader :action

    def initialize(action = nil)
      @action = action
      super(generate_message)
    end
  end

  class ActionNotImplemented < ActionError
    def generate_message
      "action #{action.inspect} not implemented"
    end
  end
end
