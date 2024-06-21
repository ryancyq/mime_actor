# frozen_string_literal: true

require_relative "mime_actor/version"

require 'active_support'

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Formatter
end
