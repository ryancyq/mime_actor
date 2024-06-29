# frozen_string_literal: true

# :markup: markdown

require "active_support/concern"
require "active_support/configurable"
require "active_support/isolated_execution_state" # required by active_support/logger
require "active_support/logger"
require "active_support/tagged_logging"

module MimeActor
  # # MimeActor Logging
  # 
  # Provides a configurable logger.
  module Logging
    extend ActiveSupport::Concern

    include ActiveSupport::Configurable

    included do
      config_accessor :logger, default: ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
    end

    private

    def fill_run_sheet(*scenes, &)
      return yield unless logger.respond_to?(:tagged)

      scenes.unshift "MimeActor" unless logger.formatter.current_tags.include?("MimeActor")

      logger.tagged(*scenes, &)
    end
  end
end
