# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

RSpec.shared_context "with scene composition" do
  let(:action_filter) { :create }
  let(:action_filters) { Array.wrap(action_filter) }
  let(:action_params) { action_filters.size > 1 ? action_filters : action_filters.first }
  let(:format_filter) { :html }
  let(:format_filters) { Array.wrap(format_filter) }
  let(:compose) { klazz.act_on_format(*format_filters, on: action_params) }
end
