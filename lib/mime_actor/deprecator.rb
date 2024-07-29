# frozen_string_literal: true

# :markup: markdown

require "active_support/deprecation"

module MimeActor
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("0.6.6", "MimeActor")
  end
end

[
  [MimeActor::Rescue::ClassMethods, { rescue_actor: "use #rescue_actor instance method" }],
  [MimeActor::Scene::ClassMethods, { act_on_format: :respond_act_to }],
  [MimeActor::Stage::ClassMethods, { actor?: "no longer supported, use Object#respond_to?" }],
  [MimeActor::Stage::ClassMethods, { dispatch_cue: "no longer support anonymous proc with rescue" }],
  [MimeActor::Stage::ClassMethods, { dispatch_act: "no longer support anonymous proc with rescue" }]
].each do |klazz, *args|
  MimeActor.deprecator.deprecate_methods(klazz, *args)
end
