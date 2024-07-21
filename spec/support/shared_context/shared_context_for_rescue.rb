# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

RSpec.shared_context "with rescuable filter" do |*filters|
  let(:error_filter) { StandardError }
  let(:error_filters) { Array.wrap(error_filter) }

  if filters.include?(:action)
    let(:action_filter) { nil }
    let(:action_filters) { Array.wrap(action_filter) }
    let(:action_params) { action_filters.size > 1 ? action_filters : action_filters.first }
  end

  if filters.include?(:format)
    let(:format_filter) { nil }
    let(:format_filters) { Array.wrap(format_filter) }
    let(:format_params) { format_filters.size > 1 ? format_filters : format_filters.first }
  end

  let(:rescuable) do
    options = {
      action: filters.include?(:action) ? action_params : nil,
      format: filters.include?(:format) ? format_params : nil,
      with:   :my_handler
    }
    klazz.rescue_act_from(*error_filters, **options)
  end
end

RSpec.shared_context "with rescuable actor handler class method" do
  let(:error_instance) { error_class.new "my error" }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:rescue_context_class) { Class.new }
  let(:rescue_context) { rescue_context_class.new }
  let(:visited_errors) { [] }
  let(:rescuable) do
    klazz.rescue_actor(
      error_instance,
      action: action_filter, format: format_filter, context: rescue_context, visited: visited_errors
    )
  end
end

RSpec.shared_context "with rescuable actor handler" do
  let(:error_instance) { error_class.new "my error" }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:visited_errors) { [] }
  let(:klazz_instance) { klazz.new }
  let(:rescuable) do
    klazz_instance.rescue_actor(
      error_instance,
      action: action_filter, format: format_filter, visited: visited_errors
    )
  end
end
