# frozen_string_literal: true

require "action_controller"
require "mime_actor"

RSpec.describe ActionController::Metal do
  let(:controller_class) { Class.new(described_class).include(MimeActor::Action) }
  let(:controller) { controller_class.new }

  let(:dispatch) { controller.dispatch(action_name, action_request, action_response) }
  let(:env) do
    {
      "REQUEST_METHOD" => "POST",
      "HTTP_ACCEPT"    => "application/json,application/xml"
    }
  end
  let(:action_request) { ActionDispatch::Request.new(env) }
  let(:action_response) { ActionDispatch::Response.new.tap { |res| res.request = action_request } }
  let(:action_name) { "new" }
  let(:act_action) { action_name.to_sym }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }

  before do
    controller_class.config.logger = stub_logger
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

    it "raises #{MimeActor::ActionNotImplemented}" do
      # proxy method is defined
      expect(controller_class.action_methods).to include(act_action.to_s)
      expect(controller_class).to be_method_defined(act_action)

      expect { dispatch }.to raise_error(
        MimeActor::ActionNotImplemented,
        "action #{act_action.inspect} not implemented"
      )
    end
  end

  describe "when actor method provided is undefined" do
    let(:actor_method) { :undefined_actor }

    before do
      controller_class.act_on_action act_action, format: %i[json html], with: actor_method
    end

    it "logs the missing actor method" do
      expect(controller_class.action_methods).not_to include(actor_method.to_s)
      expect(controller_class).not_to be_method_defined(actor_method)

      allow(stub_logger).to receive(:error)
      expect { dispatch }.not_to raise_error
      expect(stub_logger).to have_received(:error) do |&logger|
        expect(logger.call).to eq "actor error, cause: <MimeActor::ActorNotFound> :undefined_actor not found"
      end
    end

    context "when raise_on_actor_error is set" do
      before { controller_class.raise_on_actor_error = true }

      it "raises #{MimeActor::ActorNotFound}" do
        expect(controller_class.action_methods).not_to include(actor_method.to_s)
        expect(controller_class).not_to be_method_defined(actor_method)
        expect { dispatch }.to raise_error(MimeActor::ActorNotFound, ":undefined_actor not found")
      end
    end
  end
end
