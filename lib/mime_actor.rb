# frozen_string_literal: true

require_relative "mime_actor/version"

require 'active_support/dependencies/autoload'

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Act
  autoload :Scene
  autoload :Rescuer
end
