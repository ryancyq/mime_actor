# frozen_string_literal: true

# :markup: markdown

require "mime_actor/validator"

require "abstract_controller"
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

    included do
      class_attribute :acting_scenes, instance_accessor: false, instance_predicate: false, default: {}.freeze
    end

    module ClassMethods
      # Register `action` + `format` definitions.
      #
      # @param action a collection of `action`
      # @param format a single `format` or a collection of `format`
      # @param with the respond handler for the given `action` + `format`
      # @param block the `block` to be yielded for the given `action` + `format`
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
      # Each `action` gets a base method, a method defined in the class or its ancestors takes precedence.
      def act_on_action(*actions, format:, with: nil, &block)
        raise ArgumentError, "format is required" if format.nil?
        raise ArgumentError, "provide either with: or a block" if !with.nil? && block_given?

        Validator.validate!(:actions, actions)
        Validator.validate!(:format_or_formats, format)
        Validator.validate!(:callable, with) unless with.nil?
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
      def mime_actor_action_methods
        @mime_actor_action_methods ||= Module.new.tap { |mod| include mod }
      end

      def define_action_methods(actions)
        actions.each do |action|
          next if mime_actor_action_methods.method_defined?(action)

          mime_actor_action_methods.module_eval(<<-RUBY, __FILE__, __LINE__ + 1)
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
        # module methods skip `method_added`, which resets the cache in controllers
        clear_action_methods! if respond_to?(:clear_action_methods!)
      end
    end
  end
end
