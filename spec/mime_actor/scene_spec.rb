# frozen_string_literal: true

require "mime_actor/scene"

RSpec.describe MimeActor::Scene do
  let(:klazz) { Class.new.include described_class }

  describe "#act_on_format" do
    it "alias #respond_act_to" do
      expect(klazz).not_to be_method_defined(:act_on_format)
      expect(klazz.singleton_class).to be_method_defined(:act_on_format)
      expect(klazz.method(:act_on_format)).to eq klazz.method(:respond_act_to)
    end
  end

  describe "#respond_act_to" do
    describe "#action" do
      it_behaves_like "composable scene action", "nil", acceptance: false do
        let(:action_filter) { nil }
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
      end
      it_behaves_like "composable scene action", "Array of String", acceptance: false do
        let(:action_filters) { %w[index create] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: index, create" }
      end
      it_behaves_like "composable scene action", "Array of String/Symbol", acceptance: false do
        let(:action_filters) { [:index, "create"] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: create" }
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
      end
      it_behaves_like "composable scene format", "Array of Symbol", acceptance: false do
        let(:format_filters) { %i[html my_custom xml] }
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

    describe "when is called multiple times" do
      it "merges the scenes" do
        expect(klazz.acting_scenes).to be_empty
        klazz.respond_act_to(:html, on: %i[index create])
        expect(klazz.acting_scenes).to include(
          index:  Set[:html],
          create: Set[:html]
        )
        klazz.respond_act_to(:xml, on: %i[create update])
        expect(klazz.acting_scenes).to include(
          index:  Set[:html],
          create: Set[:html, :xml],
          update: Set[:xml]
        )
        klazz.respond_act_to(:json, :xml, on: %i[create show])
        expect(klazz.acting_scenes).to include(
          index:  Set[:html],
          create: Set[:html, :xml, :json],
          update: Set[:xml],
          show:   Set[:json, :xml]
        )
      end
    end
  end
end
