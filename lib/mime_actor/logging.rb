# frozen_string_literal: true

require "active_support/concern"
require "active_support/configurable"
require "active_support/logger"
require "active_support/tagged_logging"

module MimeActor
  module Logging
    extend ActiveSupport::Concern

    include ActiveSupport::Configurable

    included do
      config_accessor :logger, default: ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
    end

    private

    def fill_run_sheet(*scenes, &block)
      return yield unless logger.respond_to?(:tagged)

      unless logger.formatter.current_tags.include?("MimeActor")
        scenes.unshift "MimeActor"
      end

      logger.tagged(*scenes, &block)
    end
  end
end