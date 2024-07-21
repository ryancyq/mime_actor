# frozen_string_literal: true

# :markup: markdown
# :include: ../README.md

require "mime_actor/version"
require "mime_actor/errors"

require "active_support/dependencies/autoload"
require "active_support/deprecation"

module MimeActor
  extend ActiveSupport::Autoload

  autoload :Action
  autoload :Scene
  autoload :Stage
  autoload :Rescue
  autoload :Validator
  autoload :Logging

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(MimeActor.gem_version.bump.to_s, "MimeActor")
  end

  [
    [MimeActor::Rescue::ClassMethods, { rescue_actor: "use #rescue_actor instance method" }],
    [MimeActor::Scene::ClassMethods, { act_on_format: :respond_act_to }],
    [MimeActor::Stage::ClassMethods, { actor?: "no longer supported, use Object#respond_to?" }],
    [MimeActor::Stage::ClassMethods, { dispatch_cue: "no longer support anonymous proc with rescue" }],
    [MimeActor::Stage::ClassMethods, { dispatch_act: "no longer support anonymous proc with rescue" }]
  ].each do |klazz, *args|
    deprecator.deprecate_methods(klazz, *args)
  end
end
