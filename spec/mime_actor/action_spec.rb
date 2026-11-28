# frozen_string_literal: true

require "mime_actor"

require "action_controller"

RSpec.describe MimeActor::Action do
  include_context "with a mime_actor controller"

  let(:events) { [] }

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
      expect(klazz.new.patch).to eq "patch my stuff"
    ensure
      described_class.send(:remove_method, :patch)
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

    it "calls the handler without arguments" do
      klazz.act_on_action :create, format: :json, with: :render_act
      klazz.define_method(:render_act) { render plain: "#{act_action}/#{act_format}" }

      expect(dispatch(klazz, :create, "application/json").last.body).to eq "create/json"
    end

    it "passes only the error to the rescue handler" do
      klazz.rescue_act_from ArgumentError, with: :render_error
      klazz.define_method(:render_error) { |*args| render plain: args.map(&:class).join(",") }
      klazz.act_on_action :create, format: :json, with: -> { raise ArgumentError }

      expect(dispatch(klazz, :create, "application/json").last.body).to eq "ArgumentError"
    end

    it "rejects a lambda handler taking arguments" do
      expect { klazz.act_on_action :create, format: :html, with: ->(format) { format } }.to raise_error(
        ArgumentError, %r{must not require arguments}
      )
      expect { klazz.rescue_act_from(StandardError, with: ->(error, format) { [error, format] }) }.to raise_error(
        ArgumentError, %r{must not require more than 1 argument}
      )
    end

    it "lists actions declared after the action methods are cached" do
      klazz.action_methods
      klazz.act_on_action :show, format: :html

      expect(klazz.action_methods).to include("show")
    end

    it "keeps the mime_actor helpers out of the action methods" do
      klazz.act_on_action :show, format: :html

      expect(klazz.action_methods).to include("show")
      expect(klazz.action_methods).not_to include(
        "act_action", "act_format", "acting_scenes", "actor_rescuers", "_run_act_callbacks", "_act_callbacks"
      )
    end

    it "keeps the validators off the controller" do
      expect(klazz).not_to respond_to(:validate!)
      expect(klazz).not_to respond_to(:validate_format)
    end

    it "raises #{MimeActor::ActorNotFound} when the handler method is missing" do
      klazz.act_on_action :create, format: :html, with: :missing_handler

      expect { dispatch(klazz, :create) }.to raise_error(MimeActor::ActorNotFound, ":missing_handler not found")
    end

    context "with a handler that does not exist" do
      before do
        recorded = events
        klazz.act_before { recorded << :act_before }
        klazz.rescue_act_from(StandardError) { head :unprocessable_entity }
      end

      it "raises #{MimeActor::ActorNotFound} for a missing handler method before any act callback" do
        klazz.act_on_action :create, format: :html, with: -> { head :ok }
        klazz.act_on_action :create, format: :json, with: :missing_handler

        expect { dispatch(klazz, :create) }.to raise_error(MimeActor::ActorNotFound, ":missing_handler not found")
        expect(events).to be_empty
      end

      it "raises #{AbstractController::ActionNotFound} for a missing action method before any act callback" do
        klazz.act_on_action :create, format: :html

        expect { dispatch(klazz, :create, :html) }.to raise_error(AbstractController::ActionNotFound)
        expect(events).to be_empty
      end
    end

    it "keeps the act callbacks out of the action methods" do
      klazz.act_before { nil }
      child = Class.new(klazz) do
        act_before { nil }
        act_on_action :show, format: :html
      end

      expect(klazz.action_methods).to be_empty
      expect(child.action_methods).to eq Set["show"]
    end

    context "with an abstract #{ActionController::Metal} controller" do
      let(:abstract_controller) do
        Class.new(ActionController::Metal).tap do |k|
          k.abstract!
          k.include described_class
        end
      end

      it "dispatches only the declared actions of its subclasses" do
        child = Class.new(abstract_controller) do
          act_on_action :show, format: :html, with: -> { self.response_body = "show" }
        end

        expect(child.action_methods).to eq Set["show"]
        expect(dispatch(child, :show).last.body).to eq "show"
      end

      it "does not dispatch the actions declared in the abstract controller" do
        abstract_controller.act_on_action :index, format: :html, with: -> { self.response_body = "index" }

        expect(Class.new(abstract_controller).action_methods).to be_empty
      end
    end

    { "made private" => :private, "undefined" => :undef_method }.each do |description, visibility|
      it "does not dispatch actions #{description} by the child" do
        klazz.act_on_action :create, format: :html, with: -> { head :ok }
        klazz.act_on_action :update, format: :html
        klazz.define_method(:update) { head :ok }
        child = Class.new(klazz) { send(visibility, :create, :update) }

        expect { dispatch(child, :create, "text/html") }.to raise_error(AbstractController::ActionNotFound)
        expect { dispatch(child, :update, "text/html") }.to raise_error(AbstractController::ActionNotFound)
      end
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

    it "keeps the act for the rest of the request" do
      recorded = events
      klazz.before_action { recorded << [:before_action, act_action, act_format] }
      klazz.after_action { recorded << [:after_action, act_action, act_format] }
      klazz.act_on_action :create, format: %i[html json], with: -> { head :ok }

      expect(dispatch(klazz, :create, :json).first).to eq 200
      expect(events).to eq [%i[before_action create json], %i[after_action create json]]
    end

    context "with an act callback tagging logs" do
      let(:outputs) { [StringIO.new, StringIO.new] }
      let(:loggers) { outputs.map { |io| ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(io)) } }
      let(:logger) { loggers.first }

      before do
        klazz.logger = logger
        klazz.class_eval do
          act_around :tag_act_logs

          def tag_act_logs
            return yield unless logger.respond_to?(:push_tags)

            tags = [act_action, act_format]
            logger.push_tags(*tags)
            yield
          ensure
            logger.pop_tags(tags.size) if tags
          end
        end
        recorded = events
        klazz.act_on_action :create, format: :html do
          recorded << "acting"
          logger.info("acting")
          head :ok
        end
      end

      it "tags the act logs" do
        expect(dispatch(klazz, :create, "text/html").first).to eq 200
        expect(events).to eq ["acting"]
        expect(outputs.first.string).to include("[create] [html] acting")
      end

      context "with a broadcast logger", if: defined?(ActiveSupport::BroadcastLogger) do
        let(:logger) { ActiveSupport::BroadcastLogger.new(*loggers) }

        it "tags every logger, running the act once" do
          expect(dispatch(klazz, :create, "text/html").first).to eq 200
          expect(events).to eq ["acting"]
          expect(outputs.map(&:string)).to all(include("[create] [html] acting"))
        end
      end

      context "with a logger without tags" do
        let(:logger) { ActiveSupport::Logger.new(outputs.first) }

        it "runs the act untagged" do
          expect(dispatch(klazz, :create, "text/html").first).to eq 200
          expect(events).to eq ["acting"]
          expect(outputs.first.string).to eq "acting\n"
        end
      end
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

  describe "negotiating the act format" do
    before do
      recorded = events
      klazz.act_on_action :create, format: :html, with: -> { head :ok }
      klazz.define_method(:authenticate) do
        recorded << :authenticate
        head :unauthorized
      end
      klazz.define_method(:side_effect) { recorded << :side_effect }
    end

    it "runs the before_actions declared after the include once the format is accepted" do
      klazz.before_action :side_effect

      expect { dispatch(klazz, :create, :json) }.to raise_error(ActionController::UnknownFormat)
      expect(events).to be_empty
      expect(dispatch(klazz, :create, :html).first).to eq 200
      expect(events).to eq [:side_effect]
    end

    it "runs the before_actions declared before the include first" do
      parent = Class.new(ActionController::Base) { before_action :side_effect }
      parent.define_method(:side_effect) { (@events ||= []) << :side_effect }
      child = Class.new(parent) do
        include MimeActor::Action

        act_on_action :create, format: :html, with: -> { head :ok }
      end
      controller = child.new

      expect { dispatch(controller, :create, :json) }.to raise_error(ActionController::UnknownFormat)
      expect(controller.instance_variable_get(:@events)).to eq [:side_effect]
    end

    it "authenticates first when re-declared after the authentication" do
      klazz.before_action :authenticate
      klazz.before_action :negotiate_act_format

      expect(dispatch(klazz, :create, :json).first).to eq 401
      expect(events).to eq [:authenticate]
    end

    it "negotiates in the action when skipped" do
      recorded = events
      klazz.skip_before_action :negotiate_act_format
      klazz.before_action { recorded << act_format }

      expect { dispatch(klazz, :create, :json) }.to raise_error(ActionController::UnknownFormat)
      expect(dispatch(klazz, :create, :html).first).to eq 200
      expect(events).to eq [nil, nil]
    end

    it "negotiates again for each request of a reused controller" do
      klazz.act_on_action :show, format: :json, with: -> { render plain: "show #{act_format}" }
      controller = klazz.new

      expect(dispatch(controller, :show, :json).last.body).to eq "show json"
      expect(dispatch(controller, :create, :html).first).to eq 200
    end

    it "clears the act before the next request of a reused controller" do
      klazz.act_on_action :show, format: :json, with: -> { render plain: "show" }
      klazz.define_method(:index) { render plain: [act_action, act_format].inspect }
      controller = klazz.new

      dispatch(controller, :show, :json)
      expect(dispatch(controller, :index).last.body).to eq "[nil, nil]"
    end

    it "leaves the act unset for an action not declared" do
      klazz.define_method(:index) { render plain: [act_action, act_format].inspect }

      expect(dispatch(klazz, :index).last.body).to eq "[nil, nil]"
    end

    it "keeps the negotiated format when a later before_action changes request.format" do
      klazz.act_on_action :create, format: %i[html json], with: -> { render plain: act_format }
      klazz.before_action { request.format = :json }

      expect { dispatch(klazz, :create, :html) }.to raise_error(ActionController::UnknownFormat)
    end

    it "negotiates the request.format set by a before_action declared before the include" do
      parent = Class.new(ActionController::Base) { before_action { request.format = :json } }
      child = Class.new(parent) do
        include MimeActor::Action

        act_on_action :create, format: %i[html json], with: -> { render plain: act_format }
      end

      expect(dispatch(child, :create, :html).last.body).to eq "json"
    end

    it "keeps the act out of the view assigns" do
      klazz.act_on_action :create, format: :json, with: -> { @event = :created }
      controller = klazz.new

      dispatch(controller, :create, :json)
      expect(controller.view_assigns).to include("event" => :created)
      expect(controller.view_assigns).not_to have_key("mime_actor_act")
    end

    it "keeps the act out of the view assigns when included where _protected_ivars is defined" do
      base = Class.new(ActionController::Base)
      base.define_method(:_protected_ivars) { ActionController::Base::PROTECTED_IVARS }
      base.include described_class
      base.act_on_action :create, format: :json, with: -> { @event = :created }
      controller = base.new

      dispatch(controller, :create, :json)
      expect(controller.view_assigns).not_to have_key("mime_actor_act")
    end

    it "lets rescue_from read the act format of an error raised by a before_action" do
      klazz.rescue_from(ArgumentError) { render plain: "rescued #{act_format}" }
      klazz.before_action { raise ArgumentError }

      expect(dispatch(klazz, :create, :html).last.body).to eq "rescued html"
    end

    it "exposes the act format as request.format when a before_action sets it" do
      klazz.act_on_action :create, format: :json, with: -> { render plain: request.format.to_sym }
      klazz.before_action { request.format = act_format if act_format }

      expect(dispatch(klazz, :create, "application/xml, application/json;q=0.9").last.body).to eq "json"
    end

    it "responds to the negotiated format only" do
      klazz.act_on_action :create, format: :json, with: -> { render plain: "json" }

      _, headers, body = dispatch(klazz, :create, "application/xml, application/json;q=0.9, text/html;q=0.8")
      expect(body.body).to eq "json"
      expect(headers["Content-Type"]).to start_with "application/json"
    end
  end
end
