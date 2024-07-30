# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "active_support/callbacks"
require "active_support/code_generator"
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
      generate_act_callback_methods
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
        if format.nil?
          :act
        else
          validate!(:format, format)
          :"act_#{format}"
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

      def configure_callbacks(callbacks, actions, formats, block)
        options = {}
        options[:if] = ActionMatcher.new(actions) unless actions.nil?
        callbacks.push(block) if block

        formats = Array.wrap(formats)
        formats << nil if formats.empty?

        callbacks.each do |callback|
          formats.each do |format|
            chain = callback_chain_name(format)
            define_callback_chain(chain)
            yield chain, callback, options
          end
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
            "configure_callbacks(callbacks, action, format, block) do |chain, callback, options|",
            "set_callback(chain, :#{kind}, callback, options)",
            "end",
            "end"
          )
        end
        generator.define_cached_method(:"prepend_act_#{kind}", namespace: :mime_callbacks) do |batch|
          batch.push(
            "def prepend_act_#{kind}(*callbacks, action: nil, format: nil, &block)",
            "validate_callback_options!(action, format)",
            "configure_callbacks(callbacks, action, format, block) do |chain, callback, options|",
            "set_callback(chain, :#{kind}, callback, options.merge!(prepend: true))",
            "end",
            "end"
          )
        end
      end

      def define_act_callbacks(kind)
        module_eval(
          # def self.before_act(*callbacks, action: nil, format: nil, &block)
          #   validate_callback_options!(action, format)
          #   configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
          #     set_callback(chain, :before, callback, options)
          #   end
          # end
          #
          # def self.prepend_before_act(*callbacks, action: nil, format: nil, &block)
          #   validate_callback_options!(action, format)
          #   configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
          #     set_callback(chain, :before, callback, options.merge!(prepend: true))
          #   end
          # end
          <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{kind}_act(*callbacks, action: nil, format: nil, &block)
              validate_callback_options!(action, format)
              configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
                set_callback(chain, :#{kind}, callback, options)
              end
            end

            def self.prepend_#{kind}_act(*callbacks, action: nil, format: nil, &block)
              validate_callback_options!(action, format)
              configure_callbacks(callbacks, action, format, block) do |chain, callback, options|
                set_callback(chain, :#{kind}, callback, options.merge!(prepend: true))
              end
            end
          RUBY
        )
      end
    end

    # Callbacks invocation sequence depends on the order of callback definition.
    # (except for callbacks with `format` filter).
    #
    # @example callbacks with/without action filter
    #   before_act :my_before_act_one
    #   before_act :my_before_act_two, action: :create
    #   before_act :my_before_act_three
    #
    #   around_act :my_around_act_one
    #   around_act :my_around_act_two, action: :create
    #   around_act :my_around_act_three
    #
    #   after_act :my_after_act_one
    #   after_act :my_after_act_two, action: :create
    #   after_act :my_after_act_three
    #
    #   # actual sequence:
    #   # - my_before_act_one
    #   # - my_before_act_two
    #   # - my_before_act_three
    #   # - my_around_act_one
    #   # - my_around_act_two
    #   # - my_around_act_three
    #   # - my_after_act_three
    #   # - my_after_act_two
    #   # - my_after_act_one
    #
    # @example callbacks with format filter
    #   before_act :my_before_act_one
    #   before_act :my_before_act_two, action: :create
    #   before_act :my_before_act_three, action: :create, format: :html
    #   before_act :my_before_act_four
    #
    #   around_act :my_around_act_one
    #   around_act :my_around_act_two, action: :create, format: :html
    #   around_act :my_around_act_three, action: :create
    #   around_act :my_around_act_four
    #
    #   after_act :my_after_act_one, format: :html
    #   after_act :my_after_act_two
    #   after_act :my_after_act_three, action: :create
    #   after_act :my_after_act_four
    #
    #   # actual sequence:
    #   # - my_before_act_one
    #   # - my_before_act_two
    #   # - my_before_act_four
    #   # - my_around_act_one
    #   # - my_around_act_three
    #   # - my_around_act_four
    #   # - my_before_act_three
    #   # - my_around_act_two
    #   # - my_after_act_one
    #   # - my_after_act_four
    #   # - my_after_act_three
    #   # - my_after_act_two
    #
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
