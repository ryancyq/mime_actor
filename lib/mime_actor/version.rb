# frozen_string_literal: true

module MimeActor
  def self.version
    gem_version
  end

  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  module VERSION
    MAJOR = 0
    MINOR = 5
    BUILD = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, BUILD, PRE].compact.join(".")
  end
end
