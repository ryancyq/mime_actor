# frozen_string_literal: true

require 'active_support/concern'

module MimeActor
  module Set
    extend ActiveSupport::Concern

    include Scene
    include Rescuer
  end
end