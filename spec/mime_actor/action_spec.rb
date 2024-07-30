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
    let(:klazz_instance) { klazz.new }
    let(:scene_handler) { proc { "scene handled" } }
    let(:start) { klazz_instance.start_scene(&scene_handler) }
    let(:start_action) { :create }
    let(:stub_collector) { instance_double(ActionController::MimeResponds::Collector) }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before do
      klazz.act_on_action start_action, format: :html
      klazz.config.logger = stub_logger
      klazz.define_method(:action_name) { "placeholder" }
      allow(klazz_instance).to receive(:action_name).and_return(start_action.to_s)
    end

    context "with acting_scenes" do
      it "calls #responds_to" do
        allow(klazz_instance).to receive(:respond_to)
        expect { start }.not_to raise_error
        expect(klazz_instance).to have_received(:respond_to)
      end

      it "calls the handler" do
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
        allow(stub_collector).to receive(:html)
        expect { start }.not_to raise_error
        expect(stub_collector).to have_received(:html) do |&block|
          allow(klazz_instance).to receive(:cue_actor).and_call_original
          expect(block.call).to eq "scene handled"
          expect(klazz_instance).to have_received(:cue_actor).with(
            scene_handler, :create, :html, action: :create, format: :html
          )
        end
      end

      context "without block provided" do
        let(:start) { klazz_instance.start_scene }

        before do
          allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
          allow(stub_logger).to receive(:warn)
        end

        it "logs missing handler" do
          expect { start }.not_to raise_error
          expect(stub_logger).to have_received(:warn) do |&logger|
            expect(logger.call).to eq "no #respond_to handler found for action: :create format: :html"
          end
        end

        it "does not call #respond_to collector" do
          allow(stub_collector).to receive(:html)
          expect { start }.not_to raise_error
          expect(stub_collector).not_to have_received(:html)
        end
      end
    end

    context "without acting_scenes" do
      before do
        klazz.acting_scenes.clear
        allow(stub_logger).to receive(:warn)
      end

      it "does not call #responds_to" do
        allow(klazz_instance).to receive(:respond_to)
        expect { start }.not_to raise_error
        expect(klazz_instance).not_to have_received(:respond_to)
      end

      it "logs missing formats" do
        expect { start }.not_to raise_error
        expect(stub_logger).to have_received(:warn) do |&logger|
          expect(logger.call).to eq "no format found for action: \"create\""
        end
      end

      it "calls the handler" do
        expect(start).to eq "scene handled"
      end

      context "without block provided" do
        let(:start) { klazz_instance.start_scene }

        it "does not call #responds_to" do
          allow(klazz_instance).to receive(:respond_to)
          expect { start }.not_to raise_error
          expect(klazz_instance).not_to have_received(:respond_to)
        end
      end
    end
  end
end
