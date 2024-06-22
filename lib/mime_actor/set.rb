# frozen_string_literal: true

require 'active_support/concern'

module MimeActor
  module Set
    extend ActiveSupport::Concern

    include Formatter
    include Rescuer
  end
end