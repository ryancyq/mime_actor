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
  let(:action_format) { "json" }
  let(:action_actor) { "#{action_name}_#{action_format}" }
  let(:stub_logger) { instance_double(ActiveSupport::Logger) }

  before do
    controller_class.config.logger = stub_logger
  end

  describe "when actor method is defined" do
    before do
      controller_class.compose_scene :json, on: :new
      controller_class.define_method(action_actor) { render plain: :ok }
    end

    it "calls the actor method" do
      expect(controller_class.action_methods).to include(action_actor)
      expect(controller_class).to be_method_defined(action_actor)

      allow(controller).to receive(action_actor).and_call_original
      expect { dispatch }.not_to raise_error
      expect(controller).to have_received(action_actor)
    end
  end

  describe "when actor methods for some formats are undefined" do
    before do
      controller_class.compose_scene :json, :html, on: :new
      controller_class.define_method(:new_html) { render plain: :ok }
    end

    it "logs the missing actor method" do
      expect(controller_class.action_methods).not_to include(action_actor)
      expect(controller_class).not_to be_method_defined(action_actor)

      allow(stub_logger).to receive(:warn)
      expect { dispatch }.not_to raise_error
      expect(stub_logger).to have_received(:warn) do |&block|
        expect(block.call).to eq "actor not found, expected :new_json"
      end
    end

    context "when raise_on_missing_actor is set" do
      before { controller_class.raise_on_missing_actor = true }

      it "raises error" do
        expect(controller_class.action_methods).not_to include(action_actor)
        expect(controller_class).not_to be_method_defined(action_actor)
        expect { dispatch }.to raise_error(MimeActor::ActorNotFound, ":new_json not found")
      end
    end
  end
end
