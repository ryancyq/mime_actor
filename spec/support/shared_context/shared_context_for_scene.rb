# frozen_string_literal: true

RSpec.shared_context "with scene composition" do
  include_context "with a mime_actor controller"

  let(:action_filter) { :create }
  let(:format_filter) { :html }
  let(:compose) do
    if action_filter.is_a?(Enumerable)
      klazz.act_on_action(*action_filter, format: format_filter)
    else
      klazz.act_on_action(action_filter, format: format_filter)
    end
  end
end
