# frozen_string_literal: true

# :markup: markdown

require "active_support/version"
# required by active_support/logger
require "logger" if ActiveSupport.version < "7.1"
# required by active_support/tagged_logging
require "active_support/isolated_execution_state" if ActiveSupport.version >= "7.0"

require "active_support/concern"
require "active_support/core_ext/module/delegation"
require "active_support/logger"
require "active_support/tagged_logging"

module MimeActor
  # # MimeActor Logging
  #
  # Provides a configurable logger.
  module Logging
    extend ActiveSupport::Concern

    included do
      default_logger = -> { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new($stdout)) }

      if method_defined?(:logger)
        # keep the logger of the host, e.g. ActionController::Base, ActionController::API
        # fall back to the default when the host has none, e.g. actionpack outside of a Rails app
        self.logger ||= default_logger.call if respond_to?(:logger) && respond_to?(:logger=)
      elsif respond_to?(:config)
        # reuse the config of the host, e.g. ActionController::Metal
        # including ActiveSupport::Configurable would shadow it (Rails >= 8.1 config is a class_attribute)
        config.logger ||= default_logger.call
        singleton_class.delegate :logger, :logger=, to: :config
        delegate :logger, :logger=, to: :config
      else
        require "active_support" # active_support/configurable >= 8.1 requires ActiveSupport.deprecator
        require "active_support/configurable"
        include ActiveSupport::Configurable

        if ActiveSupport.version >= "7.0"
          config_accessor :logger, default: default_logger.call
        else
          config_accessor :logger do
            default_logger.call
          end
        end
      end
    end

    private

    # NOTE: tags are pushed on the formatter rather than yielding to `logger.tagged`,
    # since ActiveSupport::BroadcastLogger#tagged yields once per broadcast logger.
    def fill_run_sheet(*scenes)
      formatter = logger.formatter if logger.respond_to?(:formatter)
      return yield unless formatter.respond_to?(:current_tags) && formatter.respond_to?(:push_tags)

      scenes.unshift "MimeActor" unless formatter.current_tags.include?("MimeActor")
      pushed_tags = formatter.push_tags(*scenes)
      begin
        yield
      ensure
        formatter.pop_tags(pushed_tags.size)
      end
    end
  end
end
