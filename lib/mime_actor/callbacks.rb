# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "active_support/callbacks"
require "active_support/code_generator"
require "active_support/concern"
require "active_support/core_ext/module/attr_internal"

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
  # NOTE: Calling the same callback multiple times will overwrite previous callback definitions.
  #
  module Callbacks
    extend ActiveSupport::Concern

    include ActiveSupport::Callbacks
    include MimeActor::Validator

    included do
      attr_internal_reader :act_action, :act_format
      define_callbacks :act, skip_after_callbacks_if_terminated: true
      generate_act_callback_methods
    end

    module ClassMethods
      class ActMatcher
        attr_reader :actions, :formats

        def initialize(actions, formats)
          @actions = actions&.then { |a| Array(a).to_set(&:to_sym) }
          @formats = formats&.then { |f| Array(f).to_set(&:to_sym) }
        end

        def match?(controller)
          matched = true
          matched &= actions.include?(controller.act_action) if !actions.nil? && controller.respond_to?(:act_action)
          matched &= formats.include?(controller.act_format) if !formats.nil? && controller.respond_to?(:act_format)
          matched
        end

        alias after  match?
        alias before match?
        alias around match?
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
        validate!(:action_or_actions, action) unless action.nil?
        validate!(:format_or_formats, format) unless format.nil?
      end

      def generate_act_callback_methods
        ActiveSupport::CodeGenerator.batch(singleton_class, __FILE__, __LINE__) do |owner|
          %i[before after around].each do |kind|
            generate_act_callback_kind(owner, kind)
          end
        end
        # as: check against the defined method in owner, code only generated after #batch block is yielded
        ActiveSupport::CodeGenerator.batch(singleton_class, __FILE__, __LINE__) do |owner|
          %i[before after around].each do |kind|
            owner.define_cached_method(:"act_#{kind}", as: :"append_act_#{kind}", namespace: :mime_callbacks)
          end
        end
      end

      def generate_act_callback_kind(generator, kind)
        generator.define_cached_method(:"append_act_#{kind}", namespace: :mime_callbacks) do |batch|
          batch.push(
            "def append_act_#{kind}(*callbacks, action: nil, format: nil, &block)",
            "validate_callback_options!(action, format)",
            "configure_callbacks(callbacks, action, format, block) do |callback, options|",
            "set_callback(:act, :#{kind}, callback, options)",
            "end",
            "end"
          )
        end
        generator.define_cached_method(:"prepend_act_#{kind}", namespace: :mime_callbacks) do |batch|
          batch.push(
            "def prepend_act_#{kind}(*callbacks, action: nil, format: nil, &block)",
            "validate_callback_options!(action, format)",
            "configure_callbacks(callbacks, action, format, block) do |callback, options|",
            "set_callback(:act, :#{kind}, callback, options.merge!(prepend: true))",
            "end",
            "end"
          )
        end
      end
    end

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
    def run_act_callbacks(action:, format:)
      @_act_action = action.to_sym
      @_act_format = format.to_sym

      run_callbacks :act do
        yield if block_given?
      end
    end
  end
end
