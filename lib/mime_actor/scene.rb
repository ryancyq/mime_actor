# frozen_string_literal: true

require 'mime_actor/stage'

require 'active_support/concern'
require "active_support/core_ext/array/extract_options"
require "active_support/core_ext/array/wrap"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/module/attribute_accessors"
require "action_dispatch/http/mime_type"

module MimeActor
  module Scene
    extend ActiveSupport::Concern

    include Stage

    included do
      mattr_accessor :acting_scenes, instance_writer: false, default: ActiveSupport::HashWithIndifferentAccess.new
    end

    module ClassMethods
      def compose_scene(*options)
        config = options.extract_options!
        actions = Array.wrap(config[:on])

        if actions.empty?
          raise ArgumentError, "Action name can't be empty, e.g. on: :create"
        end

        options.each do |mime_type|
          unless Mime::SET.symbols.include?(mime_type.to_sym)
            raise ArgumentError, "Unsupported format: #{mime_type}"
          end

          actions.each do |action|
            if !acting_scenes.key?(action) && self.actor?(action)
              raise ArgumentError, "Action method already defined: #{action}"
            end

            acting_scenes[action] ||= Set.new
            acting_scenes[action] |= [mime_type.to_sym]

            unless self.actor?(action)
              class_eval <<-RUBY, __FILE__, __LINE__ + 1
                def #{action}
                  self.cue_actor(:play_scene, :#{action})
                end
              RUBY
            end
          end
        end
      end
    end
  end
end
