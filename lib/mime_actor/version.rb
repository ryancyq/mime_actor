# frozen_string_literal: true

# :markup: markdown

module MimeActor
  def self.version
    VERSION::STRING
  end

  def self.gem_version
    Gem::Version.new(VERSION::STRING)
  end

  module VERSION
    MAJOR = 1
    MINOR = 0
    BUILD = 1
    PRE   = nil

    STRING = [MAJOR, MINOR, BUILD, PRE].compact.join(".")
  end
end
