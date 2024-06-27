# frozen_string_literal: true

require "mime_actor/errors"
require "mime_actor/validator"

require "active_support/concern"
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  module Scene
    extend ActiveSupport::Concern

    include Validator

    included do
      mattr_accessor :acting_scenes, instance_writer: false, default: {}
    end

    module ClassMethods
      def compose_scene(*options)
        config = options.extract_options!
        validate!(:formats, options)

        actions = config[:on]
        if !actions
          raise ArgumentError, "action is required"
        elsif actions.is_a?(Enumerable)
          validate!(:actions, actions)
        else
          validate!(:action, actions)
        end

        options.each do |format|
          Array.wrap(actions).each do |action|
            action_defined = instance_methods.include?(action.to_sym) || private_instance_methods.include?(action.to_sym)
            raise MimeActor::ActionExisted, action if !acting_scenes.key?(action) && action_defined

            acting_scenes[action] ||= Set.new
            acting_scenes[action] |= [format]

            next if action_defined

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
  end
end
