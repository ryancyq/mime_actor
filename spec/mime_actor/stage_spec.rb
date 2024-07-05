# frozen_string_literal: true

require "mime_actor/stage"

require "active_support/logger"

RSpec.describe MimeActor::Stage do
  let(:klazz) { Class.new.include described_class }

  describe "#dispatch_cue" do
    it "alias #dispatch_cue" do
      expect(klazz).not_to be_method_defined(:dispatch_cue)
      expect(klazz.singleton_class).to be_method_defined(:dispatch_cue)
      expect(klazz.method(:dispatch_cue)).to eq klazz.method(:dispatch_act)
    end
  end

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
        NoMethodError, %r{undefined method `raise_on_missing_actor='}
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

  describe "#dispatch_act" do
    let(:stub_proc) { proc { to_s } }

    it "requires block" do
      expect { klazz.dispatch_act }.to raise_error(ArgumentError, "block must be provided")
    end

    it "returns a Proc" do
      dispatch = klazz.dispatch_act(&stub_proc)
      expect(dispatch).to be_a(Proc)
      expect(dispatch).not_to eq stub_proc
    end

    context "with context" do
      let(:object_class) { stub_const "MyObject", Class.new }
      let(:object_instance) { object_class.new }

      it "invokes under class context" do
        dispatch = klazz.dispatch_act(context: object_class, &stub_proc)
        expect(dispatch.call).to eq "MyObject"
        expect(stub_proc.call).to match(%r{RSpec::.*DispatchAct::WithContext:})
      end

      it "invokes under object context" do
        dispatch = klazz.dispatch_act(context: object_instance, &stub_proc)
        expect(dispatch.call).to match(%r{MyObject:})
        expect(stub_proc.call).to match(%r{RSpec::.*DispatchAct::WithContext})
      end
    end

    describe "rescue_actor" do
      before { klazz.define_singleton_method(:rescue_actor) { |*_args| "rescue" } }

      describe "when error is handled" do
        let(:object_instance) { Object.new }

        it "does not bubbles up" do
          allow(klazz).to receive(:rescue_actor).and_return(true)
          dispatch = klazz.dispatch_act(
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
          dispatch = klazz.dispatch_act { raise "my error" }

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

      let(:actor) { -> { equal?(1) } }

      it "evaluate with context" do
        allow(klazz_instance).to receive(:equal?).and_return(true)
        expect(cue).to be_truthy
        expect(klazz_instance).to have_received(:equal?).with(1)
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

      context "with block passed" do
        let(:cue) { klazz_instance.cue_actor(actor, *acting_instructions, &another_actor) }
        let(:actor) { -> { 4 } }
        let(:another_actor) { ->(num) { num**num } }

        it "yield the block wih the result from actor" do
          expect(cue).to eq 256
        end
      end
    end
  end
end
