# frozen_string_literal: true

require "mime_actor/stage"

require 'active_support/logger'

RSpec.describe MimeActor::Stage do
  let(:klazz) { Class.new.include described_class }

  describe "#raise_on_missing_actor" do
    it "allows class attribute reader" do
      expect(klazz.raise_on_missing_actor).to be_falsey
    end
    
    it "allows class attribute writter" do
      expect { klazz.raise_on_missing_actor = true }.not_to raise_error
    end

    it "allows instance reader" do
      expect(klazz.new.raise_on_missing_actor).to be_falsey
    end
    
    it "disallows instance writter" do
      expect { klazz.new.raise_on_missing_actor = true }.to raise_error(
        NoMethodError, /undefined method `raise_on_missing_actor='/
      )
    end
  end

  describe "#find_actor" do
    let(:controller) { klazz.new }
    let(:perform) { controller.send(:find_actor, :create_json) }
    let(:stub_logger) { instance_double("ActiveSupport::Logger") }

    before { klazz.config.logger = stub_logger }

    context "when actor exists in action_methods" do
      before do
        klazz.define_method(:create_json) {}
        klazz.define_method(:action_methods) { ["create_json"] }
      end
    end

    context "when actor does not exist in action_methods" do
      before do
        klazz.define_method(:action_methods) { [] }
      end

      it "logs warning message" do
        expect(stub_logger).to receive(:warn) do |&block|
          expect(block.call).to eq(
            "Actor not found: <MimeActor::ActorNotFound> :create_json not found"
          )
        end
        expect(perform).to be_nil
      end

      context "when raise_on_missing_actor" do
        before { klazz.raise_on_missing_actor = true }

        it "raises error" do
          expect { perform }.to raise_error(MimeActor::ActorNotFound, ":create_json not found")
        end
      end

    end

    context "when action_methods undefined" do
      it "logs warning message" do
        expect(stub_logger).to receive(:warn) do |&block|
          expect(block.call).to eq(
            "Actor not found: <MimeActor::ActorNotFound> :create_json not found"
          )
        end
        expect(perform).to be_nil
      end

      context "when raise_on_missing_actor" do
        before { klazz.raise_on_missing_actor = true }

        it "raises error" do
          expect { perform }.to raise_error(MimeActor::ActorNotFound, ":create_json not found")
        end
      end
    end
  end
end