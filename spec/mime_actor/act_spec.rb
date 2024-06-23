# frozen_string_literal: true

require "mime_actor/act"

RSpec.describe MimeActor::Act do
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

  describe "#dispatch_act" do
    it "invokes within object context" do
      @stub_value = 1
      dispatch = klazz.dispatch_act do
        @stub_value = 2
      end
      
      expect(dispatch).to be_kind_of(Proc)
      expect(dispatch.call).to eq 2
      expect(@stub_value).to eq 1
      expect(klazz.instance_variable_get(:@stub_value)).to eq 2
    end

    it "invokes within given context" do
      @stub_value = 1
      object_instance = Object.new
      dispatch = klazz.dispatch_act context: object_instance do
        @stub_value = 2
      end
      
      expect(dispatch).to be_kind_of(Proc)
      expect(dispatch.call).to eq 2
      expect(@stub_value).to eq 1
      expect(klazz.instance_variable_get(:@stub_value)).to be_nil
      expect(klazz.new.instance_variable_get(:@stub_value)).to be_nil
      expect(object_instance.instance_variable_get(:@stub_value)).to eq 2
    end

    context "with exception" do
      it "bubbles up" do
        dispatch = klazz.dispatch_act do
          raise "my error"
        end
      
        expect(dispatch).to be_kind_of(Proc)
        expect { dispatch.call }.to raise_error do |ex|
          expect(ex).to be_kind_of(RuntimeError)
          expect(ex.message).to eq "my error"
        end
      end

      context "with rescue_actor" do
        let(:dispatch) {
          klazz.dispatch_act do
            raise "my error"
          end
        }

        before do
          klazz.define_method(:rescue_actor) {}
        end

        it "passed on the context" do
          object_instance = Object.new
          expect(klazz).to receive(:rescue_actor).with(
            kind_of(RuntimeError), 
            a_hash_including({
              action: :abc,
              format: "xyz",
              context: object_instance
            })
          ).and_return(true)

          another_dispatch = klazz.dispatch_act(action: :abc, format: "xyz", context: object_instance) do
            raise "my another error"
          end
          expect { another_dispatch.call }.not_to raise_error
        end

        context "when error is handled" do
          it "does not bubbles up" do
            expect(klazz).to receive(:rescue_actor).with(
              kind_of(RuntimeError), 
              a_hash_including({
                action:  nil, 
                format:  nil, 
                context: klazz
              })
            ).and_return(true)
            expect(dispatch).to be_kind_of(Proc)
            expect { dispatch.call }.not_to raise_error
          end
        end

        context "when error is not handled" do
          it "bubbles up" do
            expect(klazz).to receive(:rescue_actor)
            expect(dispatch).to be_kind_of(Proc)
            expect { dispatch.call }.to raise_error do |ex|
              expect(ex).to be_kind_of(RuntimeError)
              expect(ex.message).to eq "my error"
            end
          end
        end
      end
    end
  end
  describe "#play_scene" do
    let(:controller) { klazz.new }
    let(:perform) { controller.send(:play_scene, "create") }

    context "with acting_scenes" do
      let(:stub_collector) { instance_double("ActionController::MimeResponds::Collector") }

      before do
        klazz.compose_scene :html, on: :create
      end

      it "calls responds_to" do
        expect(controller).to receive(:respond_to)
        expect { perform }.not_to raise_error
      end

      context "with actor defined" do
        let(:stub_actor) { proc { "stub_actor"} }

        it "calls dispatch_act" do
          expect(klazz).to receive(:dispatch_act).and_call_original
          expect(controller).to receive(:respond_to) { |&block| block.call stub_collector }
          expect(controller).to receive(:find_actor).with(:create, :html).and_return(stub_actor)
          expect(stub_collector).to receive(:html) { |&block| expect(block.call).to eq "stub_actor" }
          expect { perform }.not_to raise_error
        end
      end

      context "with actor undefined" do
        let(:stub_actor) { proc { "stub_actor"} }

        it "does not call dispatch_act" do
          expect(klazz).not_to receive(:dispatch_act)
          expect(controller).to receive(:respond_to) { |&block| block.call stub_collector }
          expect(controller).to receive(:find_actor)
          expect { perform }.not_to raise_error
        end
      end
    end

    context "without acting_scenes" do
      it "does not call responds_to" do
        expect(controller).not_to receive(:respond_to)
        expect { perform }.not_to raise_error
      end
    end
  end

  describe "#find_actor" do
    let(:controller) { klazz.new }
    let(:perform) { controller.send(:find_actor, :create, :json) }
    let(:stub_logger) { instance_double("ActiveSupport::BroadcastLogger") }

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
            "Actor not found: <MimeActor::ActorNotFound> actor:create_json not found for action:create, format:json"
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
            "Actor not found: <MimeActor::ActorNotFound> actor:create_json not found for action:create, format:json"
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