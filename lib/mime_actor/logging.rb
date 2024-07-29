# frozen_string_literal: true

# :markup: markdown

# required by active_support/tagged_logging
require "active_support/version"
require "active_support/isolated_execution_state" if ActiveSupport::VERSION::MAJOR >= 7

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
      if ActiveSupport::VERSION::MAJOR >= 7
        config_accessor :logger, default: default_logger
      else
        config_accessor :logger do
          default_logger
        end
      end
    end

    private

    def fill_run_sheet(*scenes, &)
      return yield unless logger.respond_to?(:tagged)

      scenes.unshift "MimeActor" unless logger.formatter.current_tags.include?("MimeActor")

      logger.tagged(*scenes, &)
    end
  end
end
