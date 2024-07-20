# frozen_string_literal: true

RSpec.shared_context "with stage cue" do
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }
  let(:cue) { klazz_instance.cue_actor(actor, *acting_instructions, action: action_filter, format: format_filter) }

  before { klazz.config.logger = stub_logger }
end
