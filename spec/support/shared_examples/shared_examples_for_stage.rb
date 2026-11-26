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
  end

  context "when actor method does not exist" do
    it "raises #{MimeActor::ActorNotFound}" do
      expect { cue }.to raise_error(MimeActor::ActorNotFound, "#{actor.inspect} not found")
    end
  end
end
