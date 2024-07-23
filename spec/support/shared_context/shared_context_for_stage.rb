# frozen_string_literal: true

require "active_support/logger"

RSpec.shared_context "with stage cue" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }
  let(:cue) do
    klazz_instance.cue_actor(actor, *acting_instructions, action: action_filter, format: format_filter)
  end

  before { klazz.config.logger = stub_logger }
end
