# frozen_string_literal: true

require "mime_actor"

require "action_controller"

RSpec.describe ActionController::Metal do
  let(:controller_class) { Class.new(described_class).include(MimeActor::Action) }
  let(:controller) { controller_class.new }

  let(:dispatch) do
    action_request = ActionDispatch::Request.new(env)
    action_response = ActionDispatch::Response.new.tap { |res| res.request = action_request }
    controller.dispatch(act_action.to_s, action_request, action_response)
  end
  let(:env) do
    {
      "REQUEST_METHOD" => "POST",
      "HTTP_ACCEPT"    => "application/json,application/xml"
    }
  end
  let(:act_action) { :new }

  before do
    env["rack.input"] = "" if ActionPack.version < Gem::Version.new("7.1")
  end

  describe "when actor method is defined" do
    before do
      controller_class.act_on_action act_action, format: :json
      controller_class.define_method(act_action) { equal?("my actor 123") }
    end

    it "calls the actor method" do
      expect(controller_class.action_methods).to include(act_action.to_s)
      expect(controller_class).to be_method_defined(act_action)

      allow(controller).to receive(:equal?)
      expect { dispatch }.not_to raise_error
      expect(controller).to have_received(:equal?).with("my actor 123")
    end
  end

  describe "when actor method is undefined" do
    before do
      controller_class.act_on_action act_action, format: :json
    end

    it "raises #{AbstractController::ActionNotFound}" do
      expect(controller_class.action_methods).to include(act_action.to_s)
      expect(controller_class).to be_method_defined(act_action)

      expect { dispatch }.to raise_error(
        AbstractController::ActionNotFound,
        "The action 'new' has no method or format handler for #{controller_class.name}"
      ) { |ex| expect([ex.controller, ex.action]).to eq [controller, "new"] }
    end
  end

  describe "when actor method provided is undefined" do
    let(:actor_method) { :undefined_actor }

    before do
      controller_class.act_on_action act_action, format: %i[json html], with: actor_method
    end

    it "raises #{MimeActor::ActorNotFound}" do
      expect(controller_class.action_methods).not_to include(actor_method.to_s)
      expect(controller_class).not_to be_method_defined(actor_method)
      expect { dispatch }.to raise_error(MimeActor::ActorNotFound, ":undefined_actor not found")
    end
  end
end
