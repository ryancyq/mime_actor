# frozen_string_literal: true

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
      ":#{actor} not found"
    end
  end

  class ActionError < Error
    attr_reader :action

    def initialize(action = nil)
      @action = action
      super(generate_message)
    end
  end

  class ActionExisted < ActionError
    def generate_message
      "Action :#{action} already existed"
    end
  end
  
  class FormatInvalid < Error
    attr_reader :format, :formats

    def initialize(format)
      @formats = case format
                 when Set, Array
                   format
                 else
                   [format]
                 end
      @format = formats.first
      super("Invalid format: #{formats.join(", ")}")
    end
  end

  class ActionFilterRequired < Error
    def initialize
      super("Action filter is required")
    end
  end

  class ActionFilterInvalid < Error
    def initialize
      super("Action filter must be Symbol")
    end
  end
end
