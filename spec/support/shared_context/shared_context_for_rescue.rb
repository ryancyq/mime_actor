# frozen_string_literal: true

RSpec.shared_context "with rescuable filter" do |*filters|
  let(:klazz) { Class.new.include described_class }
  let(:error_filter) { nil }
  let(:action_filter) { nil } if filters.include?(:action)
  let(:format_filter) { nil } if filters.include?(:format)

  let(:rescuable) do
    options = {
      action: filters.include?(:action) ? action_filter : nil,
      format: filters.include?(:format) ? format_filter : nil,
      with:   :my_handler
    }
    if error_filter.is_a?(Enumerable)
      klazz.rescue_act_from(*error_filter, **options)
    else
      klazz.rescue_act_from(error_filter, **options)
    end
  end
end

RSpec.shared_context "with rescuable actor handler" do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:error_instance) { error_class.new "my error" }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  let(:visited_errors) { [] }
  let(:rescuable) do
    klazz_instance.rescue_actor(
      error_instance,
      action: action_filter, format: format_filter, visited: visited_errors
    )
  end
end
