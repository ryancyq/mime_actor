# frozen_string_literal: true

require "action_controller"
require "mime_actor"

RSpec.describe MimeActor::Formatter do
  let(:klazz) { Class.new(ActionController::Metal).include described_class }
  
  describe "#act_on_format" do
    subject(:act) { klazz.act_on_format(*params) }

    let(:params) { Array.wrap(formats) + [actions] }
    let(:formats) { :xml }
    let(:actions) { { on: :index } }

    context "with single format and single action" do
      let(:formats) { :html }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include("create" => Set[:html])
      end

      it "defines the action method" do
        expect(klazz.action_methods).not_to include("create")
        expect { act }.not_to raise_error
        expect(klazz.action_methods).to include("create")
      end
    end

    context "with multiple formats and single action" do
      let(:formats) { [:html, :json] }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include("create" => Set[:html, :json])
      end

      it "defines the action method" do
        expect(klazz.action_methods).not_to include("create")
        expect { act }.not_to raise_error
        expect(klazz.action_methods).to include("create")
      end
    end

    context "with single format and multiple actions" do
      let(:formats) { :html }
      let(:actions) { { on: [:index, :create] } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html], 
          "create" => Set[:html] 
        })
      end

      it "defines the action methods" do
        expect(klazz.action_methods).not_to include("index", "create")
        expect { act }.not_to raise_error
        expect(klazz.action_methods).to include("index", "create")
      end
    end

    context "with multiple formats and multiple actions" do
      let(:formats) { [:html, :json, :xml] }
      let(:actions) { { on: [:index, :create, :update] } }

      it "stores config in class attributes" do
        expect(klazz.action_formatters).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html, :json, :xml],
          "create" => Set[:html, :json, :xml],
          "update" => Set[:html, :json, :xml] 
        })
      end

      it "defines the action methods" do
        expect(klazz.action_methods).not_to include("index", "create", "update")
        expect { act }.not_to raise_error
        expect(klazz.action_methods).to include("index", "create", "update")
      end
    end

    context "with multiple times calls" do
      it "merges mappings in class attributes" do
        expect(klazz.action_formatters).to be_empty
        klazz.act_on_format(:html, on: [:index, :create])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html]
        })
        klazz.act_on_format(:xml, on: [:create, :update])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html, :xml],
          "update" => Set[:xml]
        })
        klazz.act_on_format(:json, :xml, on: [:create, :show])
        expect(klazz.action_formatters).to include({ 
          "index" => Set[:html],
          "create" => Set[:html, :xml, :json],
          "update" => Set[:xml],
          "show" => Set[:json, :xml]
        })
      end
    end
  end

  describe "when dispatches an action" do
    subject(:dispatch) { controller.dispatch(action_name, req, res) }

    let(:env) do
      {
        "REQUEST_METHOD" => "POST",
        "HTTP_ACCEPT" => "application/json,application/xml"
      }
    end
    let(:controller) { klazz.new }
    let(:req) { ActionDispatch::Request.new(env) }
    let(:res) { ActionDispatch::Response.new.tap { |res| res.request = req } }
    let(:action_name) { "create" }
    let(:format) { "json" }
    let(:actor_name) { "#{action_name}_#{format}" }
    let(:stub_logger) { instance_double("ActiveSupport::BroadcastLogger") }

    before do
      klazz.config.logger = stub_logger
    end

    context "with actor method defined" do
      let(:action_name) { "debug" }
      let(:format) { "json" }

      before do
        klazz.define_method(actor_name) { @stub_value = 1 }
        klazz.act_on_format format, on: action_name
      end

      it "invokes the method within the context" do
        expect(klazz.action_methods).to include("debug_json")
        expect(@stub_value).to be_nil
        expect { dispatch }.not_to raise_error
        expect(@stub_value).to be_nil
        expect(controller.instance_variable_get(:@stub_value)).to eq 1
      end
    end

    context "without actor method defined" do
      context "when all actor methods not defined" do
        before { klazz.act_on_format format, on: action_name }

        it "raises UnknownFormat" do
          allow(stub_logger).to receive(:warn)
          expect(klazz.action_methods).not_to include(actor_name)
          expect { dispatch }.to raise_error(ActionController::UnknownFormat)
        end
      end

      context "when some actor methods not defined" do
        before do
          klazz.define_method(:create_xml) { }
          klazz.act_on_format format, :xml, on: action_name
        end

        it "logs the missing actor method" do
          expect(klazz.action_methods).not_to include(actor_name)
          expect(stub_logger).to receive(:warn) do |&block|
            expect(block.call).to eq "Method: create_json could not be found for action: create, format: json"
          end
          expect { dispatch }.not_to raise_error
        end

        context "with raise_on_missing_action_formatter set" do
          before { klazz.raise_on_missing_action_formatter = true }

          it "raises ActionNotFound" do
            expect { dispatch }.to raise_error(
              AbstractController::ActionNotFound, 
              "Method: create_json could not be found for action: create, format: json"
            )
          end
        end
      end
    end
  end
end