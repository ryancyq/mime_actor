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

  describe "class#actor?" do
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

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) { "create" }
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

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) { "create" }
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
    subject(:find) { controller.find_actor(actor_name) }

    let(:controller) { klazz.new }
    let(:stub_logger) { instance_double(ActiveSupport::Logger) }

    before { klazz.config.logger = stub_logger }

    context "when actor exists" do
      before { klazz.define_method(:supporting_actor) { "supporting" } }

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
          allow(stub_logger).to receive(:warn)
          expect(find).to be_nil
          expect(stub_logger).to have_received(:warn) do |&block|
            expect(block.call).to eq(
              "Actor not found: <MimeActor::ActorNotFound> :supporting_actor not found"
            )
          end
        end

        context "when raise_on_missing_actor" do
          before { klazz.raise_on_missing_actor = true }

          it "raises error" do
            expect { find }.to raise_error(MimeActor::ActorNotFound, ":supporting_actor not found")
          end
        end
      end

      context "with actor name in String" do
        let(:actor_name) { "supporting_actor" }

        it "logs warning message" do
          allow(stub_logger).to receive(:warn)
          expect(find).to be_nil
          expect(stub_logger).to have_received(:warn) do |&block|
            expect(block.call).to eq(
              "Actor not found: <MimeActor::ActorNotFound> :supporting_actor not found"
            )
          end
        end

        context "when raise_on_missing_actor" do
          before { klazz.raise_on_missing_actor = true }

          it "raises error" do
            expect { find }.to raise_error(MimeActor::ActorNotFound, ":supporting_actor not found")
          end
        end
      end
    end

    context "when actor exists in action_methods" do
      let(:actor_name) { :create_json }

      before do
        klazz.define_method(:create_json) { "create" }
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
        allow(stub_logger).to receive(:warn)
        expect(find).to be_nil
        expect(stub_logger).to have_received(:warn) do |&block|
          expect(block.call).to eq(
            "Actor not found: <MimeActor::ActorNotFound> :missing_actor not found"
          )
        end
      end

      context "when raise_on_missing_actor" do
        before { klazz.raise_on_missing_actor = true }

        it "raises error" do
          expect { find }.to raise_error(MimeActor::ActorNotFound, ":missing_actor not found")
        end
      end
    end
  end

  describe "#cue_actor" do
    subject { controller.cue_actor(actor_name, *acting_instructions) }

    let(:controller) { klazz.new }
    let(:acting_instructions) { [] }

    context "when actor does not exist" do
      let(:actor_name) { :unknown_actor }

      it { is_expected.to be_nil }
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

        it { is_expected.to eq "shed tears of joy when overheard the news" }
      end

      context "without insturctions" do
        before do
          klazz.define_method(actor_name) { "a meaningless truth" }
        end

        it { is_expected.to eq "a meaningless truth" }
      end

      context "with block passed" do
        let(:cue) { controller.cue_actor(actor_name, *acting_instructions, &another_block) }
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
