# frozen_string_literal: true

# :markup: markdown

module MimeActor
  def self.version
    gem_version
  end

  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 6
    BUILD = 1
    PRE   = "alpha"

    STRING = [MAJOR, MINOR, BUILD, PRE].compact.join(".")
  end
end
