# frozen_string_literal: true

# :markup: markdown

require "active_support/callbacks"
require "active_support/concern"
require "active_support/core_ext/array/extract_options"

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

    included do
      define_callbacks :act, skip_after_callbacks_if_terminated: true
    end

    module ClassMethods
      %i[before after around].each { |kind| define_act_callbacks(kind) }

      def configure_act_filters
      end

      private

      def define_act_callbacks(kind)
        module_eval(
          # def before_act
          #   configure_act_filters(callbacks, action, format, block) do |callback, options|
          #     set_callback(:act, kind, callback, options)
          #   end
          # end
          #
          # def prepend_before_act
          #   configure_act_filters(callbacks, action, format, block) do |callback, options|
          #     set_callback(:act, kind, callback, options.merge!(prepend: true))
          #   end
          # end
          <<-RUBY, __FILE__, __LINE__ + 1
            def self.#{kind}_act(*callbacks, action: nil, format: nil, &block)
              configure_act_filters(callbacks, action, format, block) do |name, options|
                set_callback(:act, kind, name, options)
              end
            end

            def self.prepend_#{kind}_act(*callbacks, action: nil, format: nil, &block)
              configure_act_filters(callbacks, action, format, block) do |callback, options|
                set_callback(:act, kind, callback, options.merge!(prepend: true))
              end
            end
          RUBY
        )
      end
    end
  end
end
