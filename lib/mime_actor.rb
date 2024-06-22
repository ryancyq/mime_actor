# frozen_string_literal: true

require_relative "mime_actor/version"

require 'active_support/dependencies/autoload'

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Formatter
  autoload :Rescuer
  autoload :Set
end
