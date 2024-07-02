# frozen_string_literal: true

RSpec.shared_context "with stage cue" do
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }
  let(:cue) { klazz_instance.cue_actor(actor, *acting_instructions) }

  before { klazz.config.logger = stub_logger }
end
