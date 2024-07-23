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
    let(:actor_name) { "create_html" }
    let(:stub_collector) { instance_double(ActionController::MimeResponds::Collector) }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before do
      klazz.respond_act_to :html, on: :create
      klazz.config.logger = stub_logger
    end

    context "with acting_scenes" do
      it "calls #responds_to" do
        allow(klazz_instance).to receive(:respond_to)
        expect { start }.not_to raise_error
        expect(klazz_instance).to have_received(:respond_to)
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
          expect(logger.call).to eq "format is empty for action: :create"
        end
      end
    end

    context "with act callbacks" do
      before do
        klazz.define_method(:action_name) { "create" }
        klazz.define_method(actor_name) { "my actor" }

        klazz.before_act :my_before_callback, action: :create
        klazz.before_act :my_html_callback, format: :html
        klazz.after_act :my_after_html_callback, action: :create, format: :html

        klazz.define_method(:my_before_callback) { "my callback" }
        klazz.define_method(:my_html_callback) { "my html" }
        klazz.define_method(:my_after_html_callback) { "my after html" }

        allow(klazz_instance).to receive(actor_name).and_call_original
        allow(klazz_instance).to receive(:my_before_callback)
        allow(klazz_instance).to receive(:my_html_callback)
        allow(klazz_instance).to receive(:my_after_html_callback)
      end

      it "run callbacks" do
        allow(klazz_instance).to receive(:respond_to).and_yield(stub_collector)

        allow(stub_collector).to receive(:html) do |&block|
          expect(block.call).to eq "my actor"
          expect(klazz_instance).to have_received(:my_before_callback).ordered
          expect(klazz_instance).to have_received(:my_html_callback).ordered
          expect(klazz_instance).to have_received(actor_name).ordered
          expect(klazz_instance).to have_received(:my_after_html_callback).ordered
        end

        expect { start }.not_to raise_error
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
          expect(klazz_instance).to have_received(:cue_actor).with(actor_name, action: :create, format: :html)
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
          block.call
          expect(klazz_instance).to have_received(:cue_actor).with(actor_name, action: :create, format: :html)
        end
      end
    end
  end
end
