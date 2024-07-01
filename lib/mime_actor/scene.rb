# frozen_string_literal: true

# :markup: markdown

require "mime_actor/errors"
require "mime_actor/validator"

require "active_support/concern"
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  # # MimeActor Scene
  #
  # Scene provides configuration for `action` + `format` definitions
  #
  # @example register a `html` format on action `index`
  #     act_on_format :html, on: :index
  # @example register `html`, `json` formats on actions `index`, `show`
  #     act_on_format :html, :json , on: [:index, :show]
  #
  # NOTE: Calling the same `action`/`format` multiple times will overwrite previous `action` + `format` definitions.
  #
  module Scene
    extend ActiveSupport::Concern

    include Validator

    included do
      mattr_accessor :acting_scenes, instance_writer: false, default: {}
    end

    class_methods do
      # Register `action` + `format` definitions.
      #
      # @param options [Array]
      # @option options [Array] klazzes the collection of `format`
      # @option options [Hash] on the collection of `action`
      #
      # @example register a `html` format on action `index`
      #   act_on_format :html, on: :index
      # @example register `html`, `json` formats on actions `index`, `show`
      #   act_on_format :html, :json , on: [:index, :show]
      #
      # For each unique `action` being registered, it will have a corresponding `action` method being defined.
      def act_on_format(*options)
        config = options.extract_options!
        validate!(:formats, options)

        case actions = config[:on]
        when Enumerable
          validate!(:actions, actions)
        when Symbol, String
          validate!(:action, actions)
        else
          raise ArgumentError, "action is required"
        end

        Array.wrap(actions).each do |action|
          options.each { |format| compose_scene(action, format) }
        end
      end

      private

      def compose_scene(action, format)
        action_defined = (instance_methods + private_instance_methods).include?(action.to_sym)
        raise MimeActor::ActionExisted, action if !acting_scenes.key?(action) && action_defined

        acting_scenes[action] ||= Set.new
        acting_scenes[action] |= [format]

        define_scene(action) unless action_defined
      end

      def define_scene(action)
        class_eval(
          # def index
          #   self.respond_to?(:start_scene) && self.start_scene(:index)
          # end
          <<-RUBY, __FILE__, __LINE__ + 1
            def #{action}
              self.respond_to?(:start_scene) && self.start_scene(:#{action})
            end
        RUBY
        )
      end
    end
  end
end
