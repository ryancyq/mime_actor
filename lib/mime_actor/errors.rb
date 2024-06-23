# frozen_string_literal: true

module MimeActor
  class Error < StandardError
  end

  class ActorNotFound < Error
    attr_reader :actor

    def initialize(actor)
      @actor = actor

      super(":#{actor} not found")
    end

    def inspect
      "<#{self.class.name}> #{message}"
    end
  end
end
