# frozen_string_literal: true

RSpec.shared_examples "stage cue actor method" do |actor_method|
  include_context "with stage cue"

  let(:actor) { actor_method }

  context "when actor method exists" do
    context "with insturctions" do
      let(:acting_instructions) { "overheard the news" }

      before do
        klazz.define_method(actor_method) do |scripts|
          "shed tears of joy when #{scripts}"
        end
      end

      it "returns result from actor" do
        expect(cue).to eq "shed tears of joy when overheard the news"
      end
    end

    context "without insturctions" do
      before do
        klazz.define_method(actor_method) { "a meaningless truth" }
      end

      it "returns result from actor" do
        expect(cue).to eq "a meaningless truth"
      end
    end

    context "with block passed" do
      let(:cue) { klazz_instance.cue_actor(actor_method, *acting_instructions, &another_block) }
      let(:another_block) { ->(num) { num**num } }

      before do
        klazz.define_method(actor_method) { 3 }
      end

      it "yield the block wih the result from actor" do
        expect(cue).to eq 27
      end
    end
  end

  context "when actor method does not exist" do
    before { allow(stub_logger).to receive(:warn).and_yield }

    it "returns nil" do
      expect(cue).to be_nil
    end

    it "logs a warning message" do
      expect(cue).to be_nil
      expect(stub_logger).to have_received(:warn) do |&block|
        expect(block.call).to eq "actor #{actor_method.inspect} not found"
      end
    end

    context "when raise_on_actor_error is set" do
      before { klazz.raise_on_actor_error = true }

      it "raises #{MimeActor::ActorNotFound}" do
        expect { cue }.to raise_error(MimeActor::ActorNotFound, "#{actor_method.inspect} not found")
      end
    end
  end
end
