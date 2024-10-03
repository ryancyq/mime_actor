# frozen_string_literal: true

# :markup: markdown

module MimeActor
  class Railtie < Rails::Railtie
    initializer "mime_actor.deprecator", before: :load_environment_config do |app|
      app.deprecators[:mime_actor] = MimeActor.deprecator if ActiveSupport.version >= "7.1"
    end
  end
end
