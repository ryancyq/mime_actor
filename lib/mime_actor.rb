# frozen_string_literal: true

# :markup: markdown
# :include: ../README.md

require "mime_actor/version"
require "mime_actor/errors"

require "active_support/dependencies/autoload"

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Action
  autoload :Scene
  autoload :Stage
  autoload :Rescue
  autoload :Validator
  autoload :Logging
end
