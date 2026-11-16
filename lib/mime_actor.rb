# frozen_string_literal: true

# :markup: markdown
# :include: ../README.md

require "active_support/version"
# active_support < 7.1 uses Logger without requiring it
require "logger" if ActiveSupport.version < Gem::Version.new("7.1")
require "active_support" # load the core before its components, required by rails >= 8.2

require "mime_actor/version"
require "mime_actor/errors"

# load mime_actor components
require "mime_actor/action"
require "mime_actor/callbacks"
require "mime_actor/rescue"
require "mime_actor/scene"
require "mime_actor/stage"
require "mime_actor/validator"

require "mime_actor/deprecator"

begin
  require "rails"
rescue LoadError
  # noop
end

require "mime_actor/railtie" if defined?(Rails::Railtie)
