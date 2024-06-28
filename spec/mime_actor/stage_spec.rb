# frozen_string_literal: true

require "mime_actor/stage"

require "active_support/logger"

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

  describe "#actor?" do
    subject { klazz.actor? actor_name }

    context "when actor exists" do
      before { klazz.define_method(:supporting_actor) { "supporting" } }

      context "with actor name in Symbol" do
        let(:actor_name) { :supporting_actor }

        it { is_expected.to be_truthy }
      end

      context "with actor name in String" do
        let(:actor_name) { "supporting_actor" }

        it { is_expected.to be_truthy }
      end
    end

    context "when actor does not exist" do
      context "with actor name in Symbol" do
        let(:actor_name) { :supporting_actor }

        it { is_expected.to be_falsey }
      end

      context "with actor name in String" do
        let(:actor_name) { "supporting_actor" }

        it { is_expected.to be_falsey }
      end
    end
  end

  describe "#dispatch_cue" do
    let(:stub_proc) { proc { to_s } }

    it "returns a Proc" do
      dispatch = klazz.dispatch_cue(&stub_proc)
      expect(dispatch).to be_a(Proc)
      expect(dispatch).not_to eq stub_proc
    end

    context "with context" do
      let(:object_class) { stub_const "MyObject", Class.new }
      let(:object_instance) { object_class.new }

      it "invokes under class context" do
        dispatch = klazz.dispatch_cue(context: object_class, &stub_proc)
        expect(dispatch.call).to eq "MyObject"
        expect(stub_proc.call).to match(/RSpec::.*DispatchCue::WithContext:/)
      end

      it "invokes under object context" do
        dispatch = klazz.dispatch_cue(context: object_instance, &stub_proc)
        expect(dispatch.call).to match(/MyObject:/)
        expect(stub_proc.call).to match(/RSpec::.*DispatchCue::WithContext/)
      end
    end

    describe "rescue_actor" do
      before { klazz.define_singleton_method(:rescue_actor) { |*_args| "rescue" } }

      describe "when error is handled" do
        let(:object_instance) { Object.new }

        it "does not bubbles up" do
          allow(klazz).to receive(:rescue_actor).and_return(true)
          dispatch = klazz.dispatch_cue(
            action:  :abc,
            format:  "xyz",
            context: object_instance
          ) { raise "my error" }

          expect { dispatch.call }.not_to raise_error
          expect(klazz).to have_received(:rescue_actor).with(
            kind_of(RuntimeError),
            a_hash_including(
              action:  :abc,
              format:  "xyz",
              context: object_instance
            )
          )
        end
      end

      describe "when error is not handled" do
        it "bubbles up" do
          allow(klazz).to receive(:rescue_actor)
          dispatch = klazz.dispatch_cue { raise "my error" }

          expect { dispatch.call }.to raise_error do |ex|
            expect(ex).to be_a(RuntimeError)
            expect(ex.message).to eq "my error"
          end
          expect(klazz).to have_received(:rescue_actor)
        end
      end
    end
  end

  describe "#cue_actor" do
    let(:cue) { klazz_instance.cue_actor(actor_name, *acting_instructions) }
    let(:klazz_instance) { klazz.new }
    let(:acting_instructions) { [] }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before { klazz.config.logger = stub_logger }

    context "when actor does not exist" do
      let(:actor_name) { :unknown_actor }

      before { allow(stub_logger).to receive(:warn).and_yield }

      it "returns nil" do
        expect(cue).to be_nil
      end

      it "logs a warning message" do
        expect(cue).to be_nil
        expect(stub_logger).to have_received(:warn) do |&block|
          expect(block.call).to eq "actor not found, expected :unknown_actor"
        end
      end

      context "when raise_on_missing_actor is set" do
        before { klazz.raise_on_missing_actor = true }

        it "raises #{MimeActor::ActorNotFound}" do
          expect { cue }.to raise_error(MimeActor::ActorNotFound, ":unknown_actor not found")
        end
      end
    end

    context "when actor exists" do
      let(:actor_name) { :lead_role }

      context "with insturctions" do
        let(:acting_instructions) { "overheard the news" }

        before do
          klazz.define_method(actor_name) do |scripts|
            "shed tears of joy when #{scripts}"
          end
        end

        it "returns result from actor" do
          expect(cue).to eq "shed tears of joy when overheard the news"
        end
      end

      context "without insturctions" do
        before do
          klazz.define_method(actor_name) { "a meaningless truth" }
        end

        it "returns result from actor" do
          expect(cue).to eq "a meaningless truth"
        end
      end

      context "with block passed" do
        let(:cue) { klazz_instance.cue_actor(actor_name, *acting_instructions, &another_block) }
        let(:another_block) { ->(num) { num**num } }

        before do
          klazz.define_method(actor_name) { 3 }
        end

        it "yield the block wih the result from actor" do
          expect(cue).to eq 27
        end
      end
    end
  end
end
