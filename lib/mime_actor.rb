# frozen_string_literal: true

require "mime_actor/version"
require "mime_actor/errors"

require 'active_support/dependencies/autoload'

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Act
  autoload :Scene
  autoload :Rescue
end
