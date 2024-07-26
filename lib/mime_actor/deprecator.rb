# frozen_string_literal: true

# :markup: markdown

require "active_support/deprecation"

module MimeActor
  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("0.8.0", "MimeActor")
  end
end
