# frozen_string_literal: true

RSpec.shared_context "with scene composition" do
  let(:klazz) { Class.new.include described_class }
  let(:action_filter) { :create }
  let(:format_filter) { :html }
  let(:compose) do
    if format_filter.is_a?(Enumerable)
      klazz.respond_act_to(*format_filter, on: action_filter)
    else
      klazz.respond_act_to(format_filter, on: action_filter)
    end
  end
end
