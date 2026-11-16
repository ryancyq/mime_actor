# frozen_string_literal: true

require "mime_actor/stage"

RSpec.describe MimeActor::Stage do
  let(:klazz) { Class.new.include described_class }

  describe "#cue_actor" do
    context "when actor is Integer" do
      include_context "with stage cue"
      let(:actor) { 200 }

      it "raises #{TypeError}" do
        expect { cue }.to raise_error(TypeError, "invalid actor, got: 200")
      end
    end

    it_behaves_like "stage cue actor method", "string_actor"
    it_behaves_like "stage cue actor method", :symbol_actor

    describe "when actor is Proc" do
      include_context "with stage cue"

      let(:actor) { -> { is_a?("anything") } }

      it "evaluate with context" do
        allow(klazz_instance).to receive(:is_a?).and_return "something"
        expect(cue).to eq "something"
        expect(klazz_instance).to have_received(:is_a?).with("anything")
      end

      context "with instructions" do
        let(:actor) { ->(scripts) { "shed tears of joy when #{scripts}" } }
        let(:acting_instructions) { "saw the news" }

        it "returns result from actor" do
          expect(cue).to eq "shed tears of joy when saw the news"
        end
      end

      context "without instructions" do
        let(:actor) { -> { "a meaninglful day" } }

        it "returns result from actor" do
          expect(cue).to eq "a meaninglful day"
        end
      end
    end

    describe "#rescue_actor" do
      include_context "with stage cue"

      let(:actor) { -> { raise "my actor error" } }
      let(:actor_error) { RuntimeError.new("my error") }
      let(:action_filter) { :abc }
      let(:format_filter) { :json }

      before { klazz.define_method(:rescue_actor) { |*_args| "rescue" } }

      describe "when error is handled" do
        it "does not bubbles up" do
          allow(klazz_instance).to receive(:rescue_actor).and_return(actor_error)
          expect(cue).to eq actor_error
          expect(klazz_instance).to have_received(:rescue_actor).with(
            kind_of(RuntimeError),
            a_hash_including(
              action: :abc,
              format: :json
            )
          )
        end
      end

      describe "when error is not handled" do
        it "bubbles up" do
          allow(klazz_instance).to receive(:rescue_actor).and_return(nil)
          expect { cue }.to raise_error do |ex|
            expect(ex).to be_a(RuntimeError)
            expect(ex.message).to eq "my actor error"
          end
          expect(klazz_instance).to have_received(:rescue_actor)
        end
      end

      describe "when error raised in callbacks" do
        let(:actor) { :my_actor }
        let(:action_filter) { :abc }
        let(:callback_error) { RuntimeError.new("my error callback") }

        before do
          klazz.define_method(actor) { "my actor" }
          allow(klazz_instance).to receive(actor).and_call_original

          klazz.act_before :my_before_callback, action: action_filter
          klazz.act_after :my_after_callback, format: format_filter
          klazz.define_method(:my_before_callback) { "before error" }
          klazz.define_method(:my_after_callback) { "after error" }
        end

        it "rescues before callback" do
          allow(klazz_instance).to receive(:my_before_callback).and_raise(callback_error)
          allow(klazz_instance).to receive(:my_after_callback)
          allow(klazz_instance).to receive(:rescue_actor).and_return(callback_error)

          expect(cue).to eq callback_error

          expect(klazz_instance).to have_received(:my_before_callback).ordered
          expect(klazz_instance).not_to have_received(actor).ordered
          expect(klazz_instance).not_to have_received(:my_after_callback).ordered
        end

        it "rescues after callback" do
          allow(klazz_instance).to receive(:my_before_callback)
          allow(klazz_instance).to receive(:my_after_callback).and_raise(callback_error)
          allow(klazz_instance).to receive(:rescue_actor).and_return(callback_error)

          expect(cue).to eq callback_error

          expect(klazz_instance).to have_received(:my_before_callback).ordered
          expect(klazz_instance).to have_received(actor).ordered
          expect(klazz_instance).to have_received(:my_after_callback).ordered
        end
      end
    end

    context "with act callbacks" do
      include_context "with stage cue"

      let(:action_filter) { :create }
      let(:format_filter) { :html }
      let(:actor) { :my_actor }

      before do
        klazz.define_method(actor) { "my actor" }

        klazz.act_before :my_before_callback, action: :create
        klazz.act_before :my_html_callback, format: :html
        klazz.act_after :my_after_html_callback, action: :create, format: :html

        klazz.define_method(:my_before_callback) { "my callback" }
        klazz.define_method(:my_html_callback) { "my html" }
        klazz.define_method(:my_after_html_callback) { "my after html" }

        allow(klazz_instance).to receive(actor).and_call_original
        allow(klazz_instance).to receive(:my_before_callback)
        allow(klazz_instance).to receive(:my_html_callback)
        allow(klazz_instance).to receive(:my_after_html_callback)
      end

      it "run callbacks" do
        expect(cue).to eq "my actor"

        expect(klazz_instance).to have_received(:my_before_callback).ordered
        expect(klazz_instance).to have_received(:my_html_callback).ordered
        expect(klazz_instance).to have_received(actor).ordered
        expect(klazz_instance).to have_received(:my_after_html_callback).ordered
      end
    end
  end

  describe "#cue_actor when the actor raises" do
    let(:klazz) do
      Class.new.tap do |k|
        k.include described_class
        k.attr_reader :seen
        k.rescue_act_from ArgumentError, with: -> { (@seen ||= []) << [act_action, act_format] }
      end
    end
    let(:klazz_instance) { klazz.new }

    it "lets the rescue handler read act_action/act_format" do
      klazz_instance.send(:cue_actor, -> { raise ArgumentError }, action: :create, format: :json)
      expect(klazz_instance.seen).to eq [%i[create json]]
      expect([klazz_instance.send(:act_action), klazz_instance.send(:act_format)]).to eq [nil, nil]
    end
  end

  describe "#cue_actor instrumentation" do
    include_context "with stage cue"

    let(:actor) { -> {} }

    it "publishes act.mime_actor" do
      payloads = []
      subscriber = ActiveSupport::Notifications.subscribe("act.mime_actor") { |*args| payloads << args.last }

      cue
      expect(payloads).to eq [{ controller: klazz.name, action: :create, format: :html }]
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
