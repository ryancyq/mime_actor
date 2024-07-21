# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "active_support/callbacks"
require "active_support/concern"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/object/blank"

module MimeActor
  # # MimeActor Callbacks
  #
  # MimeActor provides hooks during the life cycle of an act. Available callbacks are:
  #
  # - before_act
  # - around_act
  # - after_act
  #
  # NOTE: Calling the same callback multiple times will overwrite previous callback definitions.
  #
  module Callbacks
    extend ActiveSupport::Concern

    include ActiveSupport::Callbacks
    include MimeActor::Validator

    included do
      define_callbacks :act, skip_after_callbacks_if_terminated: true

      %i[before after around].each { |kind| define_act_callbacks(kind) }
    end

    module ClassMethods
      class ActionMatcher
        def initialize(actions)
          @actions = Array.wrap(actions).to_set(&:to_s)
        end

        def match?(controller)
          @actions.include?(controller.action_name)
        end

        alias after  match?
        alias before match?
        alias around match?
      end

      def callback_chain_name(format = nil)
        if format.present?
          validate!(:format, format)
          :"act_#{format}"
        else
          :act
        end
      end

      def callback_chain_defined?(name)
        !!get_callbacks(name)
      end

      private

      def define_callback_chain(name)
        return if callback_chain_defined?(name)

        define_callbacks name, skip_after_callbacks_if_terminated: true
      end

      def configure_callbacks(callbacks, action, format, block)
        chain = callback_chain_name(format)
        define_callback_chain(chain)

        options = {}
        options[:if] = ActionMatcher.new(action) if action.present?
        callbacks.push(block) if block
        callbacks.each do |callback|
          yield chain, callback, options
        end
      end

      def define_act_callbacks(kind)
        module_eval(
          # def self.before_act(*callbacks, action: nil, format: nil, &block)
          #   validate!(:action, action) if action.present?
          #   validate!(:format, format) if format.present?
          #   configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
          #     set_callback(chain, :before, callback, options)
          #   end
          # end
          #
          # def self.prepend_before_act(*callbacks, action: nil, format: nil, &block)
          #   validate!(:action, action) if action.present?
          #   validate!(:format, format) if format.present?
          #   configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
          #     set_callback(chain, :before, callback, options.merge!(prepend: true))
          #   end
          # end
          <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{kind}_act(*callbacks, action: nil, format: nil, &block)
              validate!(:action, action) if action.present?
              validate!(:format, format) if format.present?
              configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
                set_callback(chain, :#{kind}, callback, options)
              end
            end

            def self.prepend_#{kind}_act(*callbacks, action: nil, format: nil, &block)
              validate!(:action, action) if action.present?
              validate!(:format, format) if format.present?
              configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
                set_callback(chain, :#{kind}, callback, options.merge!(prepend: true))
              end
            end
          RUBY
        )
      end
    end

    def run_act_callbacks(format)
      action_chain = self.class.callback_chain_name
      format_chain = self.class.callback_chain_name(format)

      if self.class.callback_chain_defined?(format_chain)
        run_callbacks action_chain do
          run_callbacks format_chain do
            yield if block_given?
          end
        end
      else
        run_callbacks action_chain do
          yield if block_given?
        end
      end
    end
  end
end
