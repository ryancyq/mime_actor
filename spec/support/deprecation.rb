# frozen_string_literal: true

unless ENV["CI"]
  require "mime_actor"
  MimeActor.deprecator.behavior = :silence
end
