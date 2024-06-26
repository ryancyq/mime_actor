# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

RSpec.shared_context "rescuable actor handler" do
  let(:error_instance) { error_class.new "my error" }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:visited_errors) { [] }
  let(:rescuable) do
    klazz.rescue_actor(error_instance, action: action_filter, format: format_filter, visited: visited_errors)
  end
end
