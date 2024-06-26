# frozen_string_literal: true

require "mime_actor/stage"

require "active_support/concern"
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/module/attribute_accessors"

module MimeActor
  module Scene
    extend ActiveSupport::Concern

    include Stage

    included do
      mattr_accessor :acting_scenes, instance_writer: false, default: {}
    end

    module ClassMethods
      def compose_scene(*options)
        config = options.extract_options!
        actions = Array.wrap(config[:on])

        raise MimeActor::ActionFilterRequired if actions.empty?

        options.each do |mime_type|
          raise MimeActor::FormatInvalid, mime_type unless stage_formats.include?(mime_type.to_sym)

          actions.each do |action|
            raise MimeActor::ActionFilterInvalid, false unless action.is_a?(Symbol)
            raise MimeActor::ActionExisted, action if !acting_scenes.key?(action) && actor?(action)

            acting_scenes[action] ||= Set.new
            acting_scenes[action] |= [mime_type.to_sym]

            next if actor?(action)

            class_eval(
              # def index
              #   self.cue_actor(:play_scene, :index)
              # end
              <<-RUBY, __FILE__, __LINE__ + 1
                def #{action}
                  self.cue_actor(:play_scene, :#{action})
                end
              RUBY
            )
          end
        end
      end
    end
  end
end
