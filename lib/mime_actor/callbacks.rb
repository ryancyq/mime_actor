# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "active_support/callbacks"
require "active_support/concern"

module MimeActor
  # # MimeActor Callbacks
  #
  # MimeActor provides hooks during the life cycle of an act. Available callbacks are:
  #
  # - append_act_before
  # - append_act_around
  # - append_act_after
  # - act_before
  # - act_around
  # - act_after
  # - prepend_act_before
  # - prepend_act_around
  # - prepend_act_after
  #
  # An `act_before` halts the act once it responds (render, redirect or head) or throws `:abort`,
  # the remaining callbacks and the act are skipped.
  #
  # NOTE: Calling the same callback multiple times will overwrite previous callback definitions.
  #
  # Callbacks invocation sequence depends on the order of callback definition.
  #
  # @example callbacks with/without action filter
  #   act_before :my_act_before_one
  #   act_before :my_act_before_two, action: :create
  #   act_before :my_act_before_three
  #
  #   act_around :my_act_around_one
  #   act_around :my_act_around_two, action: :create
  #   act_around :my_act_around_three
  #
  #   act_after :my_act_after_one
  #   act_after :my_act_after_two, action: :create
  #   act_after :my_act_after_three
  #
  #   # actual sequence:
  #   # - my_act_before_one
  #   # - my_act_before_two
  #   # - my_act_before_three
  #   # - my_act_around_one
  #   # - my_act_around_two
  #   # - my_act_around_three
  #   # - my_act_after_three
  #   # - my_act_after_two
  #   # - my_act_after_one
  #
  # @example callbacks with format filter
  #   act_before :my_act_before_one
  #   act_before :my_act_before_two, action: :create
  #   act_before :my_act_before_three, action: :create, format: :html
  #   act_before :my_act_before_four
  #
  #   act_around :my_act_around_one
  #   act_around :my_act_around_two, action: :create, format: :html
  #   act_around :my_act_around_three, action: :create
  #   act_around :my_act_around_four
  #
  #   act_after :my_act_after_one, format: :html
  #   act_after :my_act_after_two
  #   act_after :my_act_after_three, action: :create
  #   act_after :my_act_after_four
  #
  #   # actual sequence:
  #   # - my_act_before_one
  #   # - my_act_before_two
  #   # - my_act_before_four
  #   # - my_act_before_three
  #   # - my_act_around_one
  #   # - my_act_around_two
  #   # - my_act_around_three
  #   # - my_act_around_four
  #   # - my_act_after_four
  #   # - my_act_after_three
  #   # - my_act_after_two
  #   # - my_act_after_one
  #
  module Callbacks
    extend ActiveSupport::Concern

    include ActiveSupport::Callbacks

    LIFECYCLES = %i[before after around].freeze

    TERMINATOR = lambda do |controller, result_lambda|
      halted = true
      catch(:abort) do
        result_lambda.call
        halted = false
      end
      halted || controller.performed?
    end

    included do
      define_callbacks :act, terminator: TERMINATOR, skip_after_callbacks_if_terminated: true
      # keep the callback runners out of `action_methods`
      %i[_run_act_callbacks _run_act_callbacks! _act_callbacks].each { |name| private name if method_defined?(name) }
    end

    module ClassMethods
      class ActMatcher
        attr_reader :actions, :formats

        def initialize(actions, formats)
          if RUBY_VERSION < "2.6"
            @actions = actions ? Array(actions).to_set(&:to_sym) : nil
            @formats = formats ? Array(formats).to_set(&:to_sym) : nil
          else
            @actions = actions&.then { |a| Array(a).to_set(&:to_sym) }
            @formats = formats&.then { |f| Array(f).to_set(&:to_sym) }
          end
        end

        def match?(controller)
          matched = true
          matched &= actions.include?(controller.send(:act_action)) unless actions.nil?
          matched &= formats.include?(controller.send(:act_format)) unless formats.nil?
          matched
        end

        alias after  match?
        alias before match?
        alias around match?
      end

      LIFECYCLES.each do |kind|
        { append: false, prepend: true }.each do |type, prepend|
          define_method(:"#{type}_act_#{kind}") do |*callbacks, action: nil, format: nil, &block|
            validate_callback_options!(action, format)
            configure_callbacks(callbacks, action, format, block) do |callback, options|
              set_callback(:act, kind, callback, options.merge!(prepend: prepend))
            end
          end
        end
        alias_method :"act_#{kind}", :"append_act_#{kind}"
      end

      private

      def configure_callbacks(callbacks, actions, formats, block)
        options = {}
        options[:if] = ActMatcher.new(actions, formats) unless actions.nil? && formats.nil?
        callbacks.push(block) if block

        callbacks.each do |callback|
          yield callback, options
        end
      end

      def validate_callback_options!(action, format)
        Validator.validate!(:action_or_actions, action) unless action.nil?
        Validator.validate!(:format_or_formats, format) unless format.nil?
      end
    end
  end
end
