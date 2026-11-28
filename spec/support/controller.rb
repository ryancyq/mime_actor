# frozen_string_literal: true

require "mime_actor"
require "action_controller"

module ControllerHelpers
  # Dispatches the action to the controller (a class or an instance), accepting the format or the MIME type.
  def dispatch(controller, action, accept = :html)
    controller = controller.new if controller.is_a?(Class)
    accept = Mime[accept].to_s if accept.is_a?(Symbol)
    env = { "REQUEST_METHOD" => "POST", "HTTP_ACCEPT" => accept, "HTTP_HOST" => "example.org" }
    env["rack.input"] = "" if ActionPack.version < Gem::Version.new("7.1")
    request = ActionDispatch::Request.new(env)
    response = ActionDispatch::Response.new.tap { |res| res.request = request }
    controller.dispatch(action.to_s, request, response)
  end
end

RSpec.shared_context "with a mime_actor controller" do
  let(:controller_base) { ActionController::Base }
  let(:klazz) do
    Class.new(controller_base).tap do |k|
      k.logger = nil if k.respond_to?(:logger=)
      k.include MimeActor::Action
    end
  end
  let(:klazz_instance) { klazz.new }
end

RSpec.configure do |config|
  config.include ControllerHelpers
end
