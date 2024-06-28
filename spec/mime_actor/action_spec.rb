# frozen_string_literal: true

require "mime_actor/action"

require "active_support/logger"

RSpec.describe MimeActor::Action do
  let(:klazz) { Class.new.include described_class }

  describe "ActiveSupport#on_load" do
    it "allows customization" do
      expect do
        ActiveSupport.on_load :mime_actor do
          def patch
            "patch my stuff"
          end
        end
      end.not_to raise_error

      expect(described_class).to be_method_defined(:patch)
      expect(klazz.new.patch).to eq "patch my stuff"
    end
  end

  describe "#start_scene" do
    let(:start) { klazz_instance.start_scene(:create) }
    let(:klazz_instance) { klazz.new }
    let(:compose_scene) { klazz.compose_scene :html, on: :create }
    let(:actor_name) { "create_html" }
    let(:stub_collector) { instance_double(ActionController::MimeResponds::Collector) }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before { klazz.config.logger = stub_logger }

    context "with acting_scenes" do
      before { compose_scene }

      it "calls #responds_to" do
        allow(klazz_instance).to receive(:respond_to)
        expect { start }.not_to raise_error
        expect(klazz_instance).to have_received(:respond_to)
      end
    end

    context "without acting_scenes" do
      before { allow(stub_logger).to receive(:warn) }

      it "does not call #responds_to" do
        allow(klazz_instance).to receive(:respond_to)
        expect { start }.not_to raise_error
        expect(klazz_instance).not_to have_received(:respond_to)
      end

      it "logs missing formats" do
        expect { start }.not_to raise_error
        expect(stub_logger).to have_received(:warn) do |&block|
          expect(block.call).to eq "format is empty for action :create"
        end
      end
    end

    describe "when actor is defined" do
      before do
        compose_scene
        klazz.define_method(actor_name) { "my actor" }
      end

      it "calls #dispatch_cue" do
        allow(klazz).to receive(:dispatch_cue).and_call_original
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
        allow(stub_collector).to receive(:html)

        expect { start }.not_to raise_error

        expect(klazz).to have_received(:dispatch_cue)
        expect(klazz_instance).to have_received(:respond_to)
        expect(stub_collector).to have_received(:html) { |&block| expect(block.call).to eq "my actor" }
      end
    end

    describe "when actor undefined" do
      before { compose_scene }

      it "calls #dispatch_cue" do
        allow(klazz).to receive(:dispatch_cue)
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
        allow(stub_collector).to receive(:html)

        expect { start }.not_to raise_error

        expect(klazz).to have_received(:dispatch_cue)
        expect(klazz_instance).to have_received(:respond_to)
        expect(stub_collector).to have_received(:html)
      end
    end
  end
end
