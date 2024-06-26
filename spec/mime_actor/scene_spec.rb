# frozen_string_literal: true

require "mime_actor/scene"

RSpec.describe MimeActor::Scene do
  let(:klazz) { Class.new.include described_class }

  describe "#compose_scene" do
    describe "#action" do
      it_behaves_like "composable scene action rejected", "nil" do
        let(:action_filter) { nil }
        let(:error_class_raised) { MimeActor::ActionFilterRequired }
        let(:error_message_raised) { "Action filter is required" }
      end
      it_behaves_like "composable scene action accepted", "Symbol" do
        let(:action_filter) { :create }
      end
      it_behaves_like "composable scene action accepted", "Array of Symbol" do
        let(:action_filters) { %i[index create] }
      end
      it_behaves_like "composable scene action rejected", "String" do
        let(:action_filter) { "create" }
      end
      it_behaves_like "composable scene action rejected", "Array of String" do
        let(:action_filters) { %w[index create] }
      end
      it_behaves_like "composable scene action accepted", "#new" do
        let(:action_filter) { :new }
      end
    end

    describe "supported format" do
      it_behaves_like "composable scene format accepted", "Symbol" do
        let(:format_filter) { :xml }
      end
      it_behaves_like "composable scene format accepted", "Array of Symbol" do
        let(:format_filters) { %i[html xml] }
      end
    end

    describe "unsupported format" do
      it_behaves_like "composable scene format rejected", "Symbol" do
        let(:format_filter) { :my_custom }
      end
      it_behaves_like "composable scene format rejected", "Array of Symbol" do
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
        klazz.compose_scene(:html, on: %i[index create])
        expect(klazz.acting_scenes).to include(
          index:  Set[:html],
          create: Set[:html]
        )
        klazz.compose_scene(:xml, on: %i[create update])
        expect(klazz.acting_scenes).to include(
          index:  Set[:html],
          create: Set[:html, :xml],
          update: Set[:xml]
        )
        klazz.compose_scene(:json, :xml, on: %i[create show])
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
