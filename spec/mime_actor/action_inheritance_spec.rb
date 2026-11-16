# frozen_string_literal: true

require "mime_actor"

require "action_controller"

RSpec.describe MimeActor::Action do
  let(:base_class) do
    Class.new(ActionController::Base).tap do |klazz|
      klazz.logger = nil
      klazz.include described_class
    end
  end
  let(:html_child) { Class.new(base_class) }
  let(:json_child) { Class.new(base_class) }

  def dispatch(controller_class, action, accept)
    env = { "REQUEST_METHOD" => "POST", "HTTP_ACCEPT" => accept }
    env["rack.input"] = "" if ActionPack.version < Gem::Version.new("7.1")
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

  describe "action overridden by the child" do
    before do
      base_class.act_on_action :create, format: :html
      base_class.define_method(:create) { head :ok }
      json_child.define_method(:create) { head :accepted }
    end

    it "keeps the scene of the parent" do
      expect(dispatch(json_child, :create, "text/html").first).to eq 202
      expect { dispatch(json_child, :create, "application/json") }.to raise_error(ActionController::UnknownFormat)
    end
  end

  describe "action re-declared by the child" do
    it "keeps the method of the parent" do
      base_class.define_method(:create) { head :accepted }
      json_child.act_on_action :create, format: :json

      expect(dispatch(json_child, :create, "application/json").first).to eq 202
    end
  end

  describe "child calling super into an action with only handlers" do
    before do
      base_class.act_on_action :create, format: :html, with: -> { head :ok }
      json_child.act_on_action :create, format: :json
      json_child.define_method(:create) { super() }
    end

    it "raises #{AbstractController::ActionNotFound}" do
      expect(dispatch(json_child, :create, "text/html").first).to eq 200
      expect { dispatch(json_child, :create, "application/json") }.to raise_error(AbstractController::ActionNotFound)
    end
  end
end
