# frozen_string_literal: true

# :markup: markdown

require "mime_actor/errors"
require "mime_actor/validator"

require "active_support/code_generator"
require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  # # MimeActor Scene
  #
  # Scene provides configuration for `action` + `format` definitions
  #
  # @example register a `html` format on action `index`
  #   respond_act_to :html, on: :index
  #
  #   # this method should be defined in the class
  #   def index_html; end
  # @example register `html`, `json` formats on actions `index`, `show`
  #   respond_act_to :html, :json , on: [:index, :show]
  #
  #   # these methods should be defined in the class
  #   def index_html; end
  #   def index_json; end
  #   def show_html; end
  #   def show_json; end
  # @example register a `html` format on action `index` with respond handler method
  #   respond_act_to :html, on: :index, with: :render_html
  #
  #   # this method should be defined in the class
  #   def render_html; end
  # @example register a `html` format on action `index` with respond handler proc
  #   respond_act_to :html, on: :index do
  #     render :index
  #   end
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
      # @param action a collection of `action`
      # @param format a single `format` or a collection of `format`
      # @param with the response handler for the given `action` + `format`
      # @param block the `block` to be yieled for the given `action` + `format`
      #
      # @example register a `html` format on action `create`
      #   act_on_action :create, format: :html
      #
      #   # an action method will be defined in the class
      #   def indexl; end
      # @example register `html`, `json` formats on actions `index`, `show`
      #   act_on_action :index, :show, format: [:html, :json]
      #
      #   # these action methods will be defined in the class
      #   def index; end
      #   def show; end
      # @example register a `html` format on action `index` with response handler method
      #   act_on_action :index, format: :html, with: :render_html
      #
      #   # an action method will be defined in the class
      #   def index; end
      #   # the given method should be defined in the class
      #   def render_html; end
      # @example register a `html` format on action `index` with response handler block
      #   act_on_action :html, on: :index do
      #     render :index
      #   end
      #
      #   # an action method will be defined in the class
      #   def index; end
      #
      # For each unique `action` being registered, a corresponding `action` method will be defined.
      def act_on_action(*actions, format:, with: nil, &block)
        raise ArgumentError, "format is required" if format.nil?
        raise ArgumentError, "provide either with: or a block" if !with.nil? && block_given?

        validate!(:actions, actions)
        validate!(:format_or_formats, format)
        validate!(:callable, with) unless with.nil?
        with = block if block_given?

        actions.each do |action|
          acting_scenes[action] ||= {}
          Array(format).each do |action_format|
            acting_scenes[action][action_format] = with
          end
        end

        generate_action_methods(actions)
      end

      private

      def generated_action_methods
        @generated_action_methods ||= Module.new.tap { |mod| prepend mod }
      end

      def generate_action_methods(actions)
        ActiveSupport::CodeGenerator.batch(generated_action_methods, __FILE__, __LINE__) do |owner|
          actions.each do |action|
            owner.define_cached_method(action, namespace: :mime_scene) do |batch|
              batch.push(
                "def #{action}",
                "if respond_to?(:start_scene)",
                "start_scene { raise #{MimeActor::ActionNotImplemented}, :#{action} unless defined?(super); super } ",
                "else",
                "raise #{MimeActor::ActionNotImplemented}, :#{action} unless defined?(super)",
                "super",
                "end",
                "end"
              )
            end
          end
        end
      end
    end
  end
end
