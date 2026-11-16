# frozen_string_literal: true

require "mime_actor"

require "action_controller"

# Guards the Rails internals MimeActor::Action relies on, see MimeActor::Action#method_for_action.
RSpec.describe "Rails hooks used by MimeActor::Action" do # rubocop:disable RSpec/DescribeClass
  let(:controller_base) { ActionController::Base }
  let(:klazz) do
    Class.new(controller_base).tap do |k|
      k.logger = nil
      k.include MimeActor::Action
    end
  end
  let(:controller) { klazz.new }

  def dispatch(action, accept = "text/html")
    env = { "REQUEST_METHOD" => "GET", "HTTP_ACCEPT" => accept }
    env["rack.input"] = "" if ActionPack.version < "7.1"
    request = ActionDispatch::Request.new(env)
    response = ActionDispatch::Response.new.tap { |res| res.request = request }
    controller.dispatch(action.to_s, request, response)
  end

  it "defines AbstractController::Base#method_for_action" do
    expect(AbstractController::Base).to be_private_method_defined(:method_for_action)
  end

  it "routes the action through #method_for_action and calls the method returned" do
    klazz.act_on_action :index, format: :html, with: -> { head :ok }
    allow(controller).to receive(:method_for_action).and_call_original
    allow(controller).to receive(:play_scene).and_call_original

    expect(dispatch(:index).first).to eq 200
    expect(controller).to have_received(:method_for_action).with("index")
    expect(controller).to have_received(:play_scene).once
  end

  [ActionController::Base, ActionController::API].each do |base|
    context "with #{base}" do
      let(:controller_base) { base }

      it "renders by default after the method returned" do
        klazz.act_on_action :index, format: :json
        klazz.define_method(:index) { nil }
        allow(controller).to receive(:default_render) { controller.head :accepted }

        expect(dispatch(:index, "application/json").first).to eq 202
        expect(controller).to have_received(:default_render).once
      end
    end
  end
end
