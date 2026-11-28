# frozen_string_literal: true

RSpec.shared_context "with act callbacks" do
  include_context "with a mime_actor controller"

  let(:act_format) { :html }
  let(:act_action) { :create }
  let(:run) do
    klazz.act_on_action act_action, format: act_format, with: -> { head :ok }
    dispatch(klazz_instance, act_action, act_format)
  end
end
