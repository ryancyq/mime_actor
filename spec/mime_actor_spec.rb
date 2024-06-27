# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "mime_actor"

RSpec.describe MimeActor do
  [
    "MimeActor::Action",
    "MimeActor::Scene",
    "MimeActor::Stage",
    "MimeActor::Rescue",
    "MimeActor::Validator",
    "MimeActor::Logging"
  ].each do |module_name|
    it "auto loads #{module_name}" do
      expect(module_name.safe_constantize).to be_a(Module)
    end
  end
end
