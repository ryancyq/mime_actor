# frozen_string_literal: true

require "mime_actor"

require "action_controller"

RSpec.describe MimeActor::Action do
  let(:events) { [] }
  let(:controller_base) { ActionController::Base }
  let(:klazz) do
    Class.new(controller_base).tap do |k|
      k.logger = nil
      k.include described_class
    end
  end

  def dispatch(controller_class, action, accept)
    env = { "REQUEST_METHOD" => "POST", "HTTP_ACCEPT" => accept, "HTTP_HOST" => "example.org" }
    env["rack.input"] = "" if ActionPack.version < "7.1"
    request = ActionDispatch::Request.new(env)
    response = ActionDispatch::Response.new.tap { |res| res.request = request }
    controller_class.new.dispatch(action.to_s, request, response)
  end

  describe "ActiveSupport#on_load" do
    it "allows customization" do
      expect do
        ActiveSupport.on_load :mime_actor do
          def patch
            "patch my stuff"
          end
        end
      end.not_to raise_error

      expect(described_class).to be_method_defined(:patch)
      expect(Class.new.include(described_class).new.patch).to eq "patch my stuff"
    end
  end

  describe "dispatching an action" do
    it "responds with the action method for each format" do
      klazz.act_on_action :create, format: %i[html json]
      klazz.define_method(:create) { render plain: "create #{act_format}" }

      expect(dispatch(klazz, :create, "text/html")).to include(200)
      expect(dispatch(klazz, :create, "application/json").last.body).to eq "create json"
    end

    it "rejects the formats not acted on" do
      klazz.act_on_action :create, format: :html
      klazz.define_method(:create) { head :ok }

      expect { dispatch(klazz, :create, "application/json") }.to raise_error(ActionController::UnknownFormat)
    end

    it "responds with the handler of the format" do
      klazz.act_on_action :create, format: :html, with: -> { render plain: "handler #{act_action}/#{act_format}" }

      expect(dispatch(klazz, :create, "text/html").last.body).to eq "handler create/html"
    end

    it "passes the action and format to the handler" do
      klazz.act_on_action :create, format: :json, with: :render_act
      klazz.define_method(:render_act) { |action, format| render plain: "#{action}/#{format}" }

      expect(dispatch(klazz, :create, "application/json").last.body).to eq "create/json"
    end

    it "dispatches actions not acted on as usual" do
      klazz.define_method(:index) { head :accepted }

      expect(dispatch(klazz, :index, "application/json").first).to eq 202
    end

    it "runs the act callbacks around the action and before the default render" do
      recorded = events
      klazz.act_before { recorded << "before:#{act_action}/#{act_format}" }
      klazz.act_after -> { recorded << "after" }
      klazz.act_after -> { redirect_to "/events" }, format: :html
      klazz.act_on_action :update, format: :html
      klazz.define_method(:update) { recorded << "body" }

      expect(dispatch(klazz, :update, "text/html").first).to eq 302
      expect(events).to eq ["before:update/html", "body", "after"]
    end

    context "with ActionController::API" do
      let(:controller_base) { ActionController::API }

      it "renders by default when the action does not" do
        klazz.act_on_action :create, format: :json
        klazz.define_method(:create) { nil }

        expect(dispatch(klazz, :create, "application/json").first).to eq 204
      end
    end

    it "raises #{AbstractController::ActionNotFound} when the format has neither handler nor method" do
      klazz.act_on_action :create, format: :html

      expect { dispatch(klazz, :create, "text/html") }.to raise_error(
        AbstractController::ActionNotFound, %r{The action 'create' has no method or format handler}
      )
    end

    it "lets the rescue handler read the act" do
      klazz.rescue_act_from ArgumentError, with: -> { render plain: "rescued #{act_action}/#{act_format}" }
      klazz.act_on_action :create, format: :json, with: -> { raise ArgumentError }

      expect(dispatch(klazz, :create, "application/json").last.body).to eq "rescued create/json"
    end

    it "clears the act after the action" do
      recorded = events
      klazz.after_action { recorded << [act_action, act_format] }
      klazz.act_on_action :create, format: :html, with: -> { head :ok }

      expect(dispatch(klazz, :create, "text/html").first).to eq 200
      expect(events).to eq [[nil, nil]]
    end

    it "instruments the act" do
      klazz.act_on_action :create, format: :html, with: -> { head :ok }
      payloads = []
      subscriber = ActiveSupport::Notifications.subscribe("act.mime_actor") { |*args| payloads << args.last }

      dispatch(klazz, :create, "text/html")
      expect(payloads).to eq [{ controller: klazz.name, action: :create, format: :html }]
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end
end
