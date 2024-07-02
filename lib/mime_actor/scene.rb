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
  #     respond_act_to :html, on: :index
  # @example register `html`, `json` formats on actions `index`, `show`
  #     respond_act_to :html, :json , on: [:index, :show]
  #
  # NOTE: Calling the same `action`/`format` multiple times will overwrite previous `action` + `format` definitions.
  #
  module Scene
    extend ActiveSupport::Concern

    include Validator

    included do
      mattr_accessor :acting_scenes, instance_writer: false, default: {}
    end

    module ClassMethods
      # Register `action` + `format` definitions.
      #
      # @param formats the collection of `format`
      # @param on the collection of `action`
      #
      # @example register a `html` format on action `index`
      #   respond_act_to :html, on: :index
      # @example register `html`, `json` formats on actions `index`, `show`
      #   respond_act_to :html, :json , on: [:index, :show]
      #
      # For each unique `action` being registered, it will have a corresponding `action` method being defined.
      def respond_act_to(*formats, on: nil)
        validate!(:formats, formats)

        case actions = on
        when Enumerable
          validate!(:actions, actions)
        when Symbol, String
          validate!(:action, actions)
        else
          raise ArgumentError, "action is required"
        end

        Array.wrap(actions).each do |action|
          formats.each { |format| compose_scene(action, format) }
        end
      end

      alias act_on_format respond_act_to

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
