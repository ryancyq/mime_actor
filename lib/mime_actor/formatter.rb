# frozen_string_literal: true

require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/hash/indifferent_access"

module MimeActor
  module Formatter
    extend ActiveSupport::Concern

    included do
      mattr_accessor :action_formatters, instance_writer: false, default: ActiveSupport::HashWithIndifferentAccess.new
      mattr_accessor :raise_on_missing_action_formatter, instance_writer: false, default: false
    end

    module ClassMethods
      def act_on_format(*formats_and_options)
        options = formats_and_options.extract_options!
        actions = Array.wrap(options[:on])

        formats_and_options.each do |format|
          actions.each do |action|
            action_formatters[action] ||= Set.new
            action_formatters[action] |= [format]
          end
        end
      end
    end
  end
end
