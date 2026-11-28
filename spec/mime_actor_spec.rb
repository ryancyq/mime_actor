# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "mime_actor"

RSpec.describe MimeActor do
  [
    "MimeActor::Action",
    "MimeActor::Scene",
    "MimeActor::Callbacks",
    "MimeActor::Rescue",
    "MimeActor::Validator"
  ].each do |module_name|
    it "auto loads #{module_name}" do
      expect(module_name.safe_constantize).to be_a(Module)
    end
  end
end
