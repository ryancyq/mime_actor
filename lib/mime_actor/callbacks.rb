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
      # Defines a callback that will get called right before the act is cued.
      #
      # @param block the `block` to evaluate when `with` is not provided
      #
      def before_act(*filters, &)
        set_callback(:act, :before, *filters, &)
      end

      def after_act(*filters, &)
        set_callback(:act, :after, *filters, &)
      end

      def around_act(*filters, &)
        set_callback(:act, :around, *filters, &)
      end
    end
  end
end
