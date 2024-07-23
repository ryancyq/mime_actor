# frozen_string_literal: true

RSpec.shared_examples "stage cue actor method" do |actor_method|
  include_context "with stage cue"

  let(:actor) { actor_method }

  context "when actor method exists" do
    context "with instructions" do
      let(:acting_instructions) { "overheard the news" }

      before do
        klazz.define_method(actor) do |scripts|
          "shed tears of joy when #{scripts}"
        end
      end

      it "returns result from actor" do
        expect(cue).to eq "shed tears of joy when overheard the news"
      end
    end

    context "without instructions" do
      before do
        klazz.define_method(actor) { "a meaningless truth" }
      end

      it "returns result from actor" do
        expect(cue).to eq "a meaningless truth"
      end
    end

    context "with block passed" do
      let(:cue) do
        klazz_instance.cue_actor(actor, *acting_instructions, format: format_filter, &another_block)
      end
      let(:another_block) { ->(num) { num**num } }

      before do
        klazz.define_method(actor) { 3 }
      end

      it "yield the block wih the result from actor" do
        expect(cue).to eq 27
      end
    end
  end

  context "when actor method does not exist" do
    before { allow(stub_logger).to receive(:error).and_yield }

    it "returns nil" do
      expect(cue).to be_nil
    end

    it "logs a error message" do
      expect(cue).to be_nil
      expect(stub_logger).to have_received(:error) do |&logger|
        expect(logger.call).to eq "actor error, cause: <MimeActor::ActorNotFound> #{actor.inspect} not found"
      end
    end

    context "when raise_on_actor_error is set" do
      before { klazz.raise_on_actor_error = true }

      it "raises #{MimeActor::ActorNotFound}" do
        expect { cue }.to raise_error(MimeActor::ActorNotFound, "#{actor.inspect} not found")
      end
    end
  end
end
