# frozen_string_literal: true

require "mime_actor"

require "active_support/logger"
require "active_support/tagged_logging"
require "action_controller"
require "stringio"

RSpec.describe MimeActor::Action do
  let(:null_logger) { ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(nil)) }
  let(:base_class) do
    Class.new(ActionController::Base).tap do |klazz|
      klazz.logger = null_logger
      klazz.include described_class
    end
  end
  let(:html_child) { Class.new(base_class) }
  let(:json_child) { Class.new(base_class) }

  def dispatch(controller_class, action, accept)
    env = { "REQUEST_METHOD" => "POST", "HTTP_ACCEPT" => accept }
    env["rack.input"] = "" if ActionPack.version < "7.1"
    request = ActionDispatch::Request.new(env)
    response = ActionDispatch::Response.new.tap { |res| res.request = request }
    controller_class.new.dispatch(action.to_s, request, response)
  end

  describe "acting_scenes" do
    it "does not leak registrations between siblings" do
      html_child.act_on_action :create, format: :html
      json_child.act_on_action :create, format: :json

      expect(html_child.acting_scenes).to eq(create: { html: nil })
      expect(json_child.acting_scenes).to eq(create: { json: nil })
      expect(base_class.acting_scenes).to eq({})
    end

    it "inherits parent registrations and lets the child add formats" do
      base_class.act_on_action :create, format: :html
      html_child.act_on_action :create, format: :json

      expect(html_child.acting_scenes).to eq(create: { html: nil, json: nil })
      expect(base_class.acting_scenes).to eq(create: { html: nil })
      expect(json_child.acting_scenes).to eq(create: { html: nil })
    end

    it "lets the child override an inherited format handler without changing the parent" do
      base_class.act_on_action :create, format: :html, with: :parent_handler
      html_child.act_on_action :create, format: :html, with: :child_handler

      expect(html_child.acting_scenes).to eq(create: { html: :child_handler })
      expect(base_class.acting_scenes).to eq(create: { html: :parent_handler })
    end
  end

  describe "actor_rescuers" do
    it "does not leak registrations between siblings" do
      html_child.rescue_act_from ArgumentError, format: :html, with: :handle_html

      expect(html_child.actor_rescuers.size).to eq 1
      expect(json_child.actor_rescuers).to be_empty
      expect(base_class.actor_rescuers).to be_empty
    end

    it "keeps inherited rescuers and gives local rescuers precedence" do
      base_class.rescue_act_from ArgumentError, with: -> { head :bad_request }
      base_class.define_method(:create) { raise ArgumentError }
      base_class.act_on_action :create, format: :html
      html_child.rescue_act_from ArgumentError, with: -> { head :conflict }

      expect(dispatch(base_class, :create, "text/html").first).to eq 400
      expect(dispatch(html_child, :create, "text/html").first).to eq 409
      expect(dispatch(json_child, :create, "text/html").first).to eq 400
    end
  end

  describe "raise_on_actor_error" do
    it "does not leak between siblings or to the parent" do
      html_child.raise_on_actor_error = true

      expect(html_child.raise_on_actor_error).to be true
      expect(json_child.raise_on_actor_error).to be false
      expect(base_class.raise_on_actor_error).to be false
    end
  end

  describe "action declared on both parent and child" do
    let(:events) { [] }

    before do
      recorded = events
      base_class.act_before { recorded << "act_before:#{act_action}/#{act_format}" }
      base_class.act_on_action :create, format: :html
      base_class.define_method(:create) do
        recorded << "body"
        head :ok
      end
      html_child.act_on_action :create, format: %i[html json]
    end

    it "runs the scene once" do
      expect(dispatch(html_child, :create, "application/json").first).to eq 200
      expect(events).to eq ["act_before:create/json", "body"]
    end

    it "keeps the parent scene unchanged" do
      expect { dispatch(base_class, :create, "application/json") }.to raise_error(ActionController::UnknownFormat)
      expect(events).to be_empty
    end
  end

  describe "logger" do
    let(:host_logger) { ActiveSupport::Logger.new(nil) }

    [ActionController::Base, ActionController::API].each do |controller_base|
      it "keeps the host logger of #{controller_base}" do
        logger = host_logger
        klazz = Class.new(controller_base) { self.logger = logger }
        klazz.include described_class

        expect(klazz.logger).to equal(host_logger)
        expect(klazz.new.logger).to equal(host_logger)
      end

      it "provides a default logger when #{controller_base} has none" do
        klazz = Class.new(controller_base) { self.logger = nil }
        klazz.include described_class

        expect(klazz.logger).to be_a(ActiveSupport::TaggedLogging)
        expect(controller_base.logger).to be_nil
      end
    end

    [ActionController::Base, ActionController::Metal].each do |controller_base|
      it "keeps config assigned to #{controller_base} before inclusion" do
        logger = host_logger
        klazz = Class.new(controller_base)
        klazz.config.logger = logger
        klazz.config.mime_actor_setting = "kept"
        klazz.include described_class

        expect(klazz.config.mime_actor_setting).to eq "kept"
        expect(klazz.logger).to equal(host_logger)
      end
    end

    it "provides a default logger for ActionController::Metal" do
      klazz = Class.new(ActionController::Metal).include(described_class)

      expect(klazz.logger).to be_a(ActiveSupport::TaggedLogging)
    end

    if defined?(ActiveSupport::BroadcastLogger)
      describe "when the host logger broadcasts to multiple tagged loggers" do
        let(:outputs) { [StringIO.new, StringIO.new] }
        let(:runs) { [] }
        let(:klazz) do
          targets = outputs.map { |io| ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(io)) }
          broadcast = ActiveSupport::BroadcastLogger.new(*targets)
          broadcast.formatter = targets.first.formatter # as Rails initializes Rails.logger
          Class.new(ActionController::Base) { self.logger = broadcast }.tap { |k| k.include described_class }
        end

        before do
          recorded = runs
          klazz.act_on_action :create, format: :html
          klazz.define_method(:create) do
            recorded << :create
            logger.info "inside scene"
            head :ok
          end
        end

        it "runs the scene once and tags each log line once" do
          expect(dispatch(klazz, :create, "text/html").first).to eq 200
          expect(runs).to eq [:create]
          expect(outputs.map { |io| io.string.scan("[MimeActor] [create] [html] inside scene").size }).to eq [1, 1]
        end
      end
    end

    it "runs the scene with a host logger that supports #tagged without #formatter" do
      logger = Class.new do
        def tagged(*)
          yield
        end
      end.new
      klazz = Class.new(ActionController::Base) { self.logger = logger }
      klazz.include described_class
      klazz.act_on_action :create, format: :html, with: -> { head :ok }

      expect(dispatch(klazz, :create, "text/html").first).to eq 200
    end

    describe "when the logger is removed after inclusion" do
      let(:klazz) do
        Class.new(ActionController::Base).tap do |k|
          k.include described_class
          k.logger = nil
        end
      end

      it "runs scenes" do
        klazz.act_on_action :create, format: :html, with: -> { head :ok }

        expect(dispatch(klazz, :create, "text/html").first).to eq 200
      end

      it "skips the missing scene warning" do
        klazz.define_method(:show) { start_scene { head :accepted } }

        expect(dispatch(klazz, :show, "text/html").first).to eq 202
      end

      it "skips the missing actor error log" do
        klazz.act_on_action :create, format: :html, with: :missing_handler
        klazz.define_method(:create) { head :ok }

        expect { dispatch(klazz, :create, "text/html") }.not_to raise_error
      end
    end
  end
end
