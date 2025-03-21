# frozen_string_literal: true

# :markup: markdown

require "active_support/version"
# required by active_support/logger
require "logger" if ActiveSupport.version < "7.1"
# required by active_support/tagged_logging
require "active_support/isolated_execution_state" if ActiveSupport.version >= "7.0"

require "active_support/concern"
require "active_support/configurable"
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
      default_logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout))
      if ActiveSupport.version >= "7.0"
        config_accessor :logger, default: default_logger
      else
        config_accessor :logger do
          default_logger
        end
      end
    end

    private

    def fill_run_sheet(*scenes, &block)
      return yield unless logger.respond_to?(:tagged)

      scenes.unshift "MimeActor" unless logger.formatter.current_tags.include?("MimeActor")

      logger.tagged(*scenes, &block)
    end
  end
end
