# frozen_string_literal: true

require "mime_actor/stage"

RSpec.describe MimeActor::Stage do
  let(:klazz) { Class.new.include described_class }

  describe "#dispatch_cue" do
    it "alias #dispatch_act" do
      expect(klazz).not_to be_method_defined(:dispatch_cue)
      expect(klazz.singleton_class).to be_method_defined(:dispatch_cue)
    end

    it "logs deprecation warning" do
      expect { klazz.dispatch_cue { "test" } }.to have_deprecated(
        %r{dispatch_cue is deprecated .*no longer support anonymous proc with rescue}
      )
    end
  end

  describe "#raise_on_actor_error" do
    it "allows class attribute reader" do
      expect(klazz.raise_on_actor_error).to be_falsey
    end

    it "allows class attribute writter" do
      expect { klazz.raise_on_actor_error = true }.not_to raise_error
    end

    it "allows instance reader" do
      expect(klazz.new.raise_on_actor_error).to be_falsey
    end

    it "disallows instance writter" do
      expect { klazz.new.raise_on_actor_error = true }.to raise_error(
        NoMethodError, %r{undefined method `raise_on_actor_error='}
      )
    end
  end

  describe "#actor?" do
    subject { klazz.actor? actor_name }

    context "with deprecation" do
      it "logs deprecation warning" do
        expect { klazz.actor? :any }.to have_deprecated(
          %r{actor\? is deprecated .*no longer supported, use Object#respond_to\?}
        )
      end
    end

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

    context "with deprecation" do
      it "logs deprecation warning" do
        expect { klazz.dispatch_act(&stub_proc) }.to have_deprecated(
          %r{dispatch_act is deprecated .*no longer support anonymous proc with rescue}
        )
      end
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

      context "with block passed" do
        let(:cue) do
          klazz_instance.cue_actor(actor, *acting_instructions, action: nil, format: nil, &another_actor)
        end
        let(:actor) { -> { 4 } }
        let(:another_actor) { ->(num) { num**num } }

        it "yield the block wih the result from actor" do
          expect(cue).to eq 256
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
        let(:callback_error) { RuntimeError.new("my error callback") }

        before do
          klazz.define_method(:action_name) { "abc" }
          klazz.define_method(actor) { "my actor" }
          allow(klazz_instance).to receive(actor).and_call_original

          klazz.before_act :my_before_callback, action: action_filter
          klazz.after_act :my_after_callback, format: format_filter
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
        klazz.define_method(:action_name) { "create" }
        klazz.define_method(actor) { "my actor" }

        klazz.before_act :my_before_callback, action: :create
        klazz.before_act :my_html_callback, format: :html
        klazz.after_act :my_after_html_callback, action: :create, format: :html

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
end
