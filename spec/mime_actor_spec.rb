# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "mime_actor"

RSpec.describe MimeActor do
  [
    "MimeActor::Act",
    "MimeActor::Scene",
    "MimeActor::Rescuer"
  ].each do |module_name|
    it "auto loads #{module_name}" do
      expect(module_name.safe_constantize).to be_kind_of(Module)
    end
  end
end