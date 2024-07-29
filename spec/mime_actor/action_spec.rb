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

  describe "#actor_delegator" do
    it "allows class attribute reader" do
      expect(klazz.actor_delegator).to be_a(Proc)
    end

    it "allows class attribute writter" do
      expect { klazz.actor_delegator = true }.not_to raise_error
    end

    it "allows instance reader" do
      expect(klazz.new.actor_delegator).to be_a(Proc)
    end

    it "disallows instance writter" do
      expect { klazz.new.actor_delegator = true }.to raise_error(
        NoMethodError, %r{undefined method `actor_delegator='}
      )
    end
  end

  describe "#start_scene" do
    let(:klazz_instance) { klazz.new }
    let(:start) { klazz_instance.start_scene }
    let(:start_action) { :create }
    let(:actor_name) { "create_html" }
    let(:stub_collector) { instance_double(ActionController::MimeResponds::Collector) }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before do
      klazz.respond_act_to :html, on: start_action
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

      describe "#actor_delegator" do
        before do
          allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
          allow(klazz_instance).to receive(:actor_delegator).and_call_original
          allow(stub_collector).to receive(:html)
        end

        context "when with/block is not provided" do
          let(:stub_delegator) { instance_double(Proc, call: "to_s") }

          before do
            klazz.respond_act_to :json, on: start_action
            allow(stub_collector).to receive(:json)
          end

          it "calls to get actor name" do
            expect { start }.not_to raise_error
            expect(klazz_instance).to have_received(:actor_delegator).twice
          end

          it "calls with action & format" do
            allow(klazz_instance).to receive(:actor_delegator).and_return(stub_delegator)
            expect { start }.not_to raise_error
            expect(stub_delegator).to have_received(:call).with(start_action, :html)
            expect(stub_delegator).to have_received(:call).with(start_action, :json)
          end
        end

        context "when with is provided" do
          before do
            klazz.respond_act_to :json, on: start_action, with: :all_rounder
            allow(stub_collector).to receive(:json)
          end

          it "does not call" do
            expect { start }.not_to raise_error
            expect(klazz_instance).not_to have_received(:actor_delegator).with(start_action, :json)
          end
        end

        context "when block is provided" do
          let(:empty_block) { proc {} }

          before do
            klazz.respond_act_to :json, on: start_action, &empty_block
            allow(stub_collector).to receive(:json)
          end

          it "does not call" do
            expect { start }.not_to raise_error
            expect(klazz_instance).not_to have_received(:actor_delegator).with(start_action, :json)
          end
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
    end

    describe "when actor is defined" do
      before { klazz.define_method(actor_name) { "my actor" } }

      it "calls #cue_actor" do
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
        allow(stub_collector).to receive(:html)

        expect { start }.not_to raise_error

        expect(klazz_instance).to have_received(:respond_to)
        expect(stub_collector).to have_received(:html) do |&block|
          allow(klazz_instance).to receive(:cue_actor).and_call_original
          expect(block.call).to eq "my actor"
          expect(klazz_instance).to have_received(:cue_actor).with(actor_name, :create, :html, format: :html)
        end
      end
    end

    describe "when actor undefined" do
      it "calls #cue_actor" do
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)
        allow(stub_collector).to receive(:html)

        expect { start }.not_to raise_error

        expect(klazz_instance).to have_received(:respond_to)
        expect(stub_collector).to have_received(:html) do |&block|
          allow(klazz_instance).to receive(:cue_actor)
          expect(block.call).to be_nil
          expect(klazz_instance).to have_received(:cue_actor).with(actor_name, :create, :html, format: :html)
        end
      end
    end
  end
end
