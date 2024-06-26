# frozen_string_literal: true

require "mime_actor/act"

RSpec.describe MimeActor::Act do
  let(:klazz) { Class.new.include described_class }

  describe "#dispatch_act" do
    let(:stub_proc) { proc { to_s } }

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
        expect(stub_proc.call).to match(/RSpec::.*DispatchAct::WithContext:/)
      end

      it "invokes under object context" do
        dispatch = klazz.dispatch_act(context: object_instance, &stub_proc)
        expect(dispatch.call).to match(/MyObject:/)
        expect(stub_proc.call).to match(/RSpec::.*DispatchAct::WithContext/)
      end
    end

    describe "rescue_actor" do
      before { klazz.define_method(:rescue_actor) { "rescue" } }

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

  describe "#play_scene" do
    let(:play) { controller.send(:play_scene, :create) }
    let(:controller) { klazz.new }
    let(:compose_scene) { klazz.compose_scene :html, on: :create }
    let(:actor_name) { "create_html" }
    let(:stub_collector) { instance_double(ActionController::MimeResponds::Collector) }

    context "with acting_scenes" do
      before { compose_scene }

      it "calls #responds_to" do
        allow(controller).to receive(:respond_to)
        expect { play }.not_to raise_error
        expect(controller).to have_received(:respond_to)
      end
    end

    context "without acting_scenes" do
      it "does not call #responds_to" do
        allow(controller).to receive(:respond_to)
        expect { play }.not_to raise_error
        expect(controller).not_to have_received(:respond_to)
      end
    end

    describe "when actor is defined" do
      before do
        compose_scene
        klazz.define_method(actor_name) { "my actor" }
      end

      it "calls #dispatch_act" do
        allow(klazz).to receive(:dispatch_act).and_call_original
        allow(controller).to receive(:respond_to).and_yield(stub_collector)
        allow(controller).to receive(:find_actor).and_call_original
        allow(stub_collector).to receive(:html)

        expect { play }.not_to raise_error

        expect(klazz).to have_received(:dispatch_act)
        expect(controller).to have_received(:respond_to)
        expect(controller).to have_received(:find_actor).with("create_html")
        expect(stub_collector).to have_received(:html) { |&block| expect(block.call).to eq "my actor" }
      end
    end

    describe "when actor undefined" do
      before { compose_scene }

      it "does not calls #dispatch_act" do
        allow(klazz).to receive(:dispatch_act).and_call_original
        allow(controller).to receive(:respond_to).and_yield(stub_collector)
        allow(controller).to receive(:find_actor)
        allow(stub_collector).to receive(:html)

        expect { play }.not_to raise_error

        expect(klazz).not_to have_received(:dispatch_act)
        expect(controller).to have_received(:respond_to)
        expect(controller).to have_received(:find_actor).with("create_html")
        expect(stub_collector).not_to have_received(:html)
      end
    end
  end
end
