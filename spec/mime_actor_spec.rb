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

  describe "#deprecator" do
    let(:deprecate) { deprecator.warn "my deprecation" }

    context "when warn using #{described_class.deprecator}" do
      let(:deprecator) { described_class.deprecator }

      it "warn deprecation" do
        expect { deprecate }.to warn_deprecation(%r{my deprecation})
      end
    end

    context "when warn using #{ActiveSupport::Deprecation}" do
      let(:deprecator) { ActiveSupport::Deprecation.new }

      it "warn deprecation" do
        expect { deprecate }.not_to warn_deprecation(%r{my deprecation})
      end
    end
  end
end
