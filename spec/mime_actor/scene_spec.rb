# frozen_string_literal: true

require "mime_actor/scene"

RSpec.describe MimeActor::Scene do
  let(:klazz) { Class.new.include described_class }

  describe "#act_on_format" do
    it "alias #respond_act_to" do
      expect(klazz).not_to be_method_defined(:act_on_format)
      expect(klazz.singleton_class).to be_method_defined(:act_on_format)
    end

    it "logs deprecation warning" do
      expect { klazz.act_on_format(:html, on: :show) }.to have_deprecated(
        %r{act_on_format is deprecated .*use respond_act_to instead}
      )
    end
  end

  describe "#respond_act_to" do
    describe "#action" do
      it_behaves_like "composable scene action", "nil", acceptance: false do
        let(:action_filter) { nil }
        let(:error_class_raised) { ArgumentError }
        let(:error_message_raised) { "action is required" }
      end
      it_behaves_like "composable scene action", "Symbol" do
        let(:action_filter) { :create }
      end
      it_behaves_like "composable scene action", "Array of Symbol" do
        let(:action_filters) { %i[index create] }
      end
      it_behaves_like "composable scene action", "String", acceptance: false do
        let(:action_filter) { "create" }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "action must be a Symbol" }
      end
      it_behaves_like "composable scene action", "Array of String", acceptance: false do
        let(:action_filters) { %w[index create] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: \"index\", \"create\"" }
      end
      it_behaves_like "composable scene action", "Array of String/Symbol", acceptance: false do
        let(:action_filters) { [:index, "create"] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: \"create\"" }
      end
      it_behaves_like "composable scene action", "#new" do
        let(:action_filter) { :new }
      end
    end

    describe "supported format" do
      it_behaves_like "composable scene format", "Symbol" do
        let(:format_filter) { :xml }
      end
      it_behaves_like "composable scene format", "Array of Symbol" do
        let(:format_filters) { %i[html xml] }
      end
    end

    describe "unsupported format" do
      it_behaves_like "composable scene format", "Symbol", acceptance: false do
        let(:format_filter) { :my_custom }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid formats, got: :my_custom" }
      end
      it_behaves_like "composable scene format", "Array of Symbol", acceptance: false do
        let(:format_filters) { %i[html my_custom xml] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid formats, got: :my_custom" }
      end
    end

    describe "action method" do
      it_behaves_like "composable scene action method", "single format, single action" do
        let(:action_filter) { :index }
        let(:format_filter) { :json }
      end
      it_behaves_like "composable scene action method", "multiple formats, single action" do
        let(:action_filter) { :show }
        let(:format_filters) { %i[html json xml] }
      end
      it_behaves_like "composable scene action method", "single format, multiple actions" do
        let(:action_filters) { %i[index create] }
        let(:format_filter) { :xml }
      end
      it_behaves_like "composable scene action method", "multiple formats, multiple actions" do
        let(:format_filters) { %i[json pdf] }
        let(:action_filters) { %i[create update] }
      end
    end

    describe "#with" do
      describe "when block is not given" do
        let(:compose) { klazz.respond_act_to :html, on: :create }

        it "optional" do
          expect { compose }.not_to raise_error
        end
      end

      describe "when block is given" do
        let(:empty_block) { proc {} }
        let(:compose) { klazz.respond_act_to :html, on: :create, with: proc {}, &empty_block }

        it "must be absent" do
          expect { compose }.to raise_error(ArgumentError, "provide either the with: argument or a block")
        end
      end

      it_behaves_like "composable scene with handler", "Proc", Proc do
        let(:handler) { proc {} }
      end
      it_behaves_like "composable scene with handler", "Lambda", Proc do
        let(:handler) { -> {} }
      end
      it_behaves_like "composable scene with handler", "Symbol", Symbol do
        let(:handler) { :custom_handler }
      end
      it_behaves_like "composable scene with handler", "String", String, acceptance: false do
        let(:handler) { "custom_handler" }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "with handler must be a Symbol or Proc, got: #{handler.inspect}" }
      end
      it_behaves_like "composable scene with handler", "Method", Method, acceptance: false do
        let(:handler) { method(:to_s) }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "with handler must be a Symbol or Proc, got: #{handler.inspect}" }
      end
    end

    describe "#block" do
      let(:empty_block) { proc {} }
      let(:compose) { klazz.respond_act_to :html, on: :show, &empty_block }

      it "be the handler" do
        expect(klazz.acting_scenes).to be_empty
        expect { compose }.not_to raise_error
        expect(klazz.acting_scenes).not_to be_empty
        expect(klazz.acting_scenes).to include(show: { html: kind_of(Proc) })
      end
    end

    describe "when is called multiple times" do
      it "merges the scenes" do
        expect(klazz.acting_scenes).to be_empty
        klazz.respond_act_to(:html, on: %i[index create])
        expect(klazz.acting_scenes).to include(
          index:  { html: anything },
          create: { html: anything }
        )
        klazz.respond_act_to(:xml, on: %i[create update])
        expect(klazz.acting_scenes).to include(
          index:  { html: anything },
          create: { html: anything, xml: anything },
          update: { xml: anything }
        )
        klazz.respond_act_to(:json, :xml, on: %i[create show])
        expect(klazz.acting_scenes).to include(
          index:  { html: anything },
          create: { html: anything, xml: anything, json: anything },
          update: { xml: anything },
          show:   { json: anything, xml: anything }
        )
      end
    end
  end
end
