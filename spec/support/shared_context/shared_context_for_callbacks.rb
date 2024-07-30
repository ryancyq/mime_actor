# frozen_string_literal: true

RSpec.shared_context "with act callbacks" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:act_format) { :html }
  let(:act_action) { :create }
  let(:run) { klazz_instance.run_act_callbacks(action: act_action, format: act_format) }
end
