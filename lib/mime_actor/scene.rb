# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "active_support/concern"
require "active_support/core_ext/class/attribute"

module MimeActor
  # # MimeActor Scene
  #
  # Scene provides configuration for `action` + `format` definitions
  #
  # @example register a `html` format on action `create`
  #   act_on_action :create, format: :html
  #
  # @example register `html`, `json` formats on actions `index`, `show`
  #   act_on_action :index, :show, format: [:html, :json]
  #
  # @example register a `html` format on action `index` with respond handler method
  #   act_on_action :index, format: :html, with: :render_html
  #
  # @example register a `html` format on action `index` with respond handler Proc
  #   act_on_action :index, format: :html, with: -> { render html: "<h1>my header</h1>" }
  #
  # @example register a `html` format on action `index` with respond handler block
  #   act_on_action :index, format: :html do
  #     render :index
  #   end
  #
  # NOTE: Calling the same `action`/`format` multiple times will overwrite previous `action` + `format` definitions.
  #
  module Scene
    extend ActiveSupport::Concern

    include Validator

    included do
      class_attribute :acting_scenes, instance_writer: false, instance_predicate: false, default: {}.freeze
    end

    module ClassMethods
      # Register `action` + `format` definitions.
      #
      # @param action a collection of `action`
      # @param format a single `format` or a collection of `format`
      # @param with the respond handler for the given `action` + `format`
      # @param block the `block` to be yieled for the given `action` + `format`
      #
      # @example register a `html` format on action `create`
      #   act_on_action :create, format: :html
      #
      # @example register `html`, `json` formats on actions `index`, `show`
      #   act_on_action :index, :show, format: [:html, :json]
      #
      # @example register a `html` format on action `index` with respond handler method
      #   act_on_action :index, format: :html, with: :render_html
      #
      #   # the given method should be defined in the class
      #   def render_html; end
      #
      # @example register a `html` format on action `index` with respond handler Proc
      #   act_on_action :index, format: :html, with: -> { render html: "<h1>my header</h1>" }
      #
      # @example register a `html` format on action `index` with respond handler block
      #   act_on_action :index, format: :html do
      #     render :index
      #   end
      #
      # Each `action` gets a base method, so an `action` with only respond handlers is still routable.
      # A method defined for the `action` in the class or its ancestors takes precedence over the base method.
      def act_on_action(*actions, format:, with: nil, &block)
        raise ArgumentError, "format is required" if format.nil?
        raise ArgumentError, "provide either with: or a block" if !with.nil? && block_given?

        validate!(:actions, actions)
        validate!(:format_or_formats, format)
        validate!(:callable, with) unless with.nil?
        with = block if block_given?

        register_acting_scenes(actions, format, with)
        define_action_methods(actions)
      end

      private

      # copy-on-write, registrations must not leak into the parent class or sibling classes
      def register_acting_scenes(actions, format, with)
        scenes = acting_scenes.dup
        actions.each do |action|
          action_formats = scenes.fetch(action, {}).dup
          Array(format).each do |action_format|
            action_formats[action_format] = with
          end
          scenes[action] = action_formats.freeze
        end
        self.acting_scenes = scenes.freeze
      end

      # included rather than prepended, a method defined in the class wins
      def action_methods_module
        @action_methods_module ||= Module.new.tap { |mod| include mod }
      end

      def define_action_methods(actions)
        actions.each do |action|
          next if action_methods_module.method_defined?(action)

          action_methods_module.module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
            # def create
            #   return super if defined?(super)
            #
            #   message = "The action 'create' has no method or format handler for \#{self.class.name}"
            #   raise AbstractController::ActionNotFound.new(message, self, "create")
            # end
            def #{action}
              return super if defined?(super)

              message = "The action '#{action}' has no method or format handler for \#{self.class.name}"
              raise AbstractController::ActionNotFound.new(message, self, "#{action}")
            end
          RUBY
        end
      end
    end
  end
end
