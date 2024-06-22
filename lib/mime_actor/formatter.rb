# frozen_string_literal: true

require 'active_support'
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/module/attribute_accessors"
require 'action_controller'

module MimeActor
  module Formatter
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable
    include AbstractController::Logger
    include AbstractController::Rendering # required by MimeResponds
    include ActionController::MimeResponds

    included do
      mattr_accessor :action_formatters, instance_writer: false, default: ActiveSupport::HashWithIndifferentAccess.new
      mattr_accessor :raise_on_missing_action_formatter, instance_writer: false, default: false
    end

    module ClassMethods
      def act_on_format(*formats_and_options)
        options = formats_and_options.extract_options!
        actions = Array.wrap(options[:on])

        message = "Action name can't be blank, e.g. on: :create"
        raise ArgumentError, message if actions.empty?

        formats_and_options.each do |format|
          message = "Unsupported format: #{format}"
          raise ArgumentError, message unless SUPPORTED_MIME_TYPES.include?(format.to_sym)

          actions.each do |action|
            message = "Action method already defined: #{action}"
            raise ArgumentError, message if action_methods.include?(action.to_s) && !action_formatters.key?(action)

            action_formatters[action] ||= Set.new
            action_formatters[action] |= [format]

            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{action}
                perform_act
              end
            RUBY
          end
        end
      end
    end

    private

    def perform_act
      return unless action_formatters.key?(action_name)

      formatters = action_formatters.fetch(action_name, Set.new)
      respond_to do |collector|
        formatters.each do |formatter|
          next unless actor = find_actor(action_name, formatter)

          collector.public_send(formatter, &actor)
        end
      end
    end

    def find_actor(action, format)
      actor_name = "#{action}_#{format}"
      
      unless action_methods.include?(actor_name)
        message = "Method: #{actor_name} could not be found for action: #{action_name}, format: #{format}"
        raise AbstractController::ActionNotFound.new(message, self, actor_name) if raise_on_missing_action_formatter

        logger.warn { message }
        return
      end

      self.method(actor_name)
    end
  end
end
