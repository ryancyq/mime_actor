# frozen_string_literal: true

# :markup: markdown
# :include: ../README.md

require "active_support/version"
# active_support < 7.1 uses Logger without requiring it
require "logger" if ActiveSupport.version < Gem::Version.new("7.1")
require "active_support" # load the core before its components, required by rails >= 8.2

require "mime_actor/version"
require "mime_actor/errors"
require "mime_actor/action"
