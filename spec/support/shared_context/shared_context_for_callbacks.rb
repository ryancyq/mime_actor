# frozen_string_literal: true

RSpec.shared_context "with act callbacks" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:act_format) { :html }
  let(:act_action) { :create }
  let(:run) { klazz_instance.run_act_callbacks(act_format) }

  before do
    klazz.define_method(:action_name) { "something" }
    allow(klazz_instance).to receive(:action_name).and_return(act_action.to_s)
  end
end
