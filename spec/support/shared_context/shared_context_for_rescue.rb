# frozen_string_literal: true

RSpec.shared_context "with rescuable filter" do |*filters|
  include_context "with a mime_actor controller"
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
  include_context "with a mime_actor controller"
  let(:error_instance) { error_class.new "my error" }
  let(:action_filter) { nil }
  let(:format_filter) { nil }
  # the error rescued by the act, `nil` when no handler matched
  let(:rescuable) do
    error = error_instance
    klazz.act_on_action action_filter || :create, format: format_filter || :html, with: -> { raise error }
    rescued = []
    allow(klazz_instance).to receive(:rescue_act).and_wrap_original do |method, *args|
      method.call(*args).tap { |result| rescued << result }
    end
    begin
      dispatch(klazz_instance, action_filter || :create, format_filter || :html)
    rescue error.class
      nil
    end
    rescued.last
  end
end
