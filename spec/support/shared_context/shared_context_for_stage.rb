# frozen_string_literal: true

RSpec.shared_context "with stage cue" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:action_filter) { :create }
  let(:format_filter) { :html }
  let(:cue) do
    klazz_instance.send(:cue_actor, actor, *acting_instructions, action: action_filter, format: format_filter)
  end
end
