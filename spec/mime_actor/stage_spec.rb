# frozen_string_literal: true

require "mime_actor/stage"

require 'active_support/logger'

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

  describe "class#actor?" do
    subject { klazz.actor? actor_name }

    context "when actor exists" do
      before { klazz.define_method(:supporting_actor) {} }

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

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) {}
        klazz.define_singleton_method(:action_methods) { ["create_json"] }
      end

      it { is_expected.to be_truthy }
    end

    context "when actor does not exist in action_methods" do
      let(:actor_name) { :missing_actor }

      before do
        klazz.define_singleton_method(:action_methods) { [] }
      end

      it { is_expected.to be_falsey }
    end
  end

  describe "#actor?" do
    subject { controller.actor? actor_name }
    let(:controller) { klazz.new }

    context "when actor exists" do
      before { klazz.define_method(:supporting_actor) {} }

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

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) {}
        klazz.define_method(:action_methods) { ["create_json"] }
      end

      it { is_expected.to be_truthy }
    end

    context "when actor does not exist in action_methods" do
      let(:actor_name) { :missing_actor }

      before do
        klazz.define_method(:action_methods) { [] }
      end

      it { is_expected.to be_falsey }
    end
  end

  describe "#find_actor" do
    subject { controller.find_actor(actor_name) }

    let(:controller) { klazz.new }
    let(:stub_logger) { instance_double("ActiveSupport::Logger") }

    before { klazz.config.logger = stub_logger }

    context "when actor exists" do
      before { klazz.define_method(:supporting_actor) {} }

      context "with actor name in Symbol" do
        let(:actor_name) { :supporting_actor }

        it { is_expected.to eq controller.method(:supporting_actor) }
      end

      context "with actor name in String" do
        let(:actor_name) { "supporting_actor" }
        
        it { is_expected.to eq controller.method(:supporting_actor) }
      end
    end

    context "when actor does not exist" do
      context "with actor name in Symbol" do
        let(:actor_name) { :supporting_actor }

        it "logs warning message" do
          expect(stub_logger).to receive(:warn) do |&block|
            expect(block.call).to eq(
              "Actor not found: <MimeActor::ActorNotFound> :supporting_actor not found"
            )
          end
          is_expected.to be_nil
        end

        context "when raise_on_missing_actor" do
          before { klazz.raise_on_missing_actor = true }

          it "raises error" do
            expect { is_expected }.to raise_error(MimeActor::ActorNotFound, ":supporting_actor not found")
          end
        end
      end

      context "with actor name in String" do
        let(:actor_name) { "supporting_actor" }
        
        it "logs warning message" do
          expect(stub_logger).to receive(:warn) do |&block|
            expect(block.call).to eq(
              "Actor not found: <MimeActor::ActorNotFound> :supporting_actor not found"
            )
          end
          is_expected.to be_nil
        end

        context "when raise_on_missing_actor" do
          before { klazz.raise_on_missing_actor = true }

          it "raises error" do
            expect { is_expected }.to raise_error(MimeActor::ActorNotFound, ":supporting_actor not found")
          end
        end
      end
    end

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) {}
        klazz.define_method(:action_methods) { ["create_json"] }
      end

      it { is_expected.to eq controller.method(:create_json) }
    end

    context "when actor does not exist in action_methods" do
      let(:actor_name) { :missing_actor }

      before do
        klazz.define_method(:action_methods) { [] }
      end

      it "logs warning message" do
        expect(stub_logger).to receive(:warn) do |&block|
          expect(block.call).to eq(
            "Actor not found: <MimeActor::ActorNotFound> :missing_actor not found"
          )
        end
        is_expected.to be_nil
      end

      context "when raise_on_missing_actor" do
        before { klazz.raise_on_missing_actor = true }

        it "raises error" do
          expect { is_expected }.to raise_error(MimeActor::ActorNotFound, ":missing_actor not found")
        end
      end
    end
  end
end