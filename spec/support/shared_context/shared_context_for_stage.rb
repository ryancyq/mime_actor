# frozen_string_literal: true

require "active_support/logger"

RSpec.shared_context "with stage cue" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:action_filter) { :create }
  let(:format_filter) { :html }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }
  let(:cue) do
    klazz_instance.cue_actor(actor, *acting_instructions, format: format_filter)
  end

  before do
    klazz.define_method(:action_name) { "placeholder" }
    allow(klazz_instance).to receive(:action_name).and_return(action_filter.to_s)
    klazz.config.logger = stub_logger
  end
end
