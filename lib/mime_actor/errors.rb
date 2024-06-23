# frozen_string_literal: true

module MimeActor
  class Error < StandardError
  end

  class ActorNotFound < Error
    attr_reader :actor, :action, :format

    def initialize(action, format)
      @action = action
      @format = format
      @actor = "#{action}_#{format}"

      super(":#{actor} not found")
    end

    def inspect
      "<#{self.class.name}> actor:#{actor} not found for action:#{action}, format:#{format}"
    end
  end
end