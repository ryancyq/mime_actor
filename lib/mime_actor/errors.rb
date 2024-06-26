# frozen_string_literal: true

require "set"

module MimeActor
  class Error < StandardError
    def inspect
      "<#{self.class.name}> #{message}"
    end
  end

  class ActorNotFound < Error
    attr_reader :actor

    def initialize(actor)
      @actor = actor
      super(":#{actor} not found")
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
      super(generate_message)
    end

    private

    def generate_message
      if formats.size > 1
        "Invalid formats: #{formats.join(", ")}"
      else
        "Invalid format: #{format}"
      end
    end
  end
end
