# frozen_string_literal: true

require "active_support/version"
# required by active_support/logger
require "logger" if ActiveSupport.version < "7.1"

require "active_support/logger"
require "active_support/tagged_logging"

RSpec.shared_context "with stage cue" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:acting_instructions) { [] }
  let(:action_filter) { :create }
  let(:format_filter) { :html }
  let(:log_output) { nil }
  let(:stub_logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(log_output)) }
  let(:cue) do
    klazz_instance.cue_actor(actor, *acting_instructions, action: action_filter, format: format_filter)
  end

  before do
    klazz.config.logger = stub_logger
  end
end
