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
    attr_reader :format

    def initialize(format)
      @format = case format
                when Set, Array
                  format
                else
                  [format]
                end
      super("Invalid format: #{@format.join(", ")}")
    end
  end

  class FormatFilterInvalid < Error
    def initialize(collection = true)
      types = ["Symbol"]
      types << "Enumerable" if collection
      super("Format filter must be #{types.join(" or ")}")
    end
  end

  class ActionFilterRequired < Error
    def initialize
      super("Action filter is required")
    end
  end

  class ActionFilterInvalid < Error
    def initialize(collection = true)
      types = ["Symbol"]
      types << "Enumerable" if collection
      super("Action filter must be #{types.join(" or ")}")
    end
  end
end
