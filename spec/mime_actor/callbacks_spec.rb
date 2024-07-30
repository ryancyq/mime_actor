# frozen_string_literal: true

require "mime_actor/callbacks"

RSpec.describe MimeActor::Callbacks do
  %i[before after around].each do |kind|
    it_behaves_like "runnable act callbacks", kind

    it_behaves_like "runnable act callbacks action filter", kind, "Nil" do
      let(:action_filter) { nil }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Empty Array", acceptance: false do
      let(:action_filter) { [] }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "actions must not be empty" }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Symbol" do
      let(:action_filter) { :show }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of Symbol" do
      let(:action_filter) { %i[show update] }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "String", acceptance: false do
      let(:action_filter) { "index" }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "action must be a Symbol" }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of String", acceptance: false do
      let(:action_filter) { %w[index update] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid actions, got: \"index\", \"update\"" }
    end
    it_behaves_like "runnable act callbacks action filter", kind, "Array of String/Symbol", acceptance: false do
      let(:action_filter) { [:index, "update"] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid actions, got: \"update\"" }
    end

    it_behaves_like "runnable act callbacks format filter", kind, "Nil" do
      let(:format_filter) { nil }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Empty Array", acceptance: false do
      let(:format_filter) { [] }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "formats must not be empty" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Symbol" do
      let(:format_filter) { :html }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of Symbol" do
      let(:format_filter) { %i[html json] }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Unsupported format", acceptance: false do
      let(:format_filter) { :something }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid format, got: :something" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of Unsupported format", acceptance: false do
      let(:format_filter) { %i[html something json] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: :something" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "String", acceptance: false do
      let(:format_filter) { "json" }
      let(:error_class_raised) { TypeError }
      let(:error_message_raised) { "format must be a Symbol" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of String", acceptance: false do
      let(:format_filter) { %w[html json] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: \"html\", \"json\"" }
    end
    it_behaves_like "runnable act callbacks format filter", kind, "Array of String/Symbol", acceptance: false do
      let(:format_filter) { [:html, "json"] }
      let(:error_class_raised) { NameError }
      let(:error_message_raised) { "invalid formats, got: \"json\"" }
    end
  end

  describe "act callbacks sequence" do
    let(:klazz) { Class.new.include described_class }
    let(:klazz_instance) { klazz.new }
    let(:sequence) { [] }

    before do
      before_callbacks
      around_callbacks
      after_callbacks

      klazz.define_method(:method_missing) { |*_args| "missed" }
      klazz.define_method(:respond_to_missing?) { |*_args| "responded" }

      allow(klazz_instance).to receive(:method_missing).and_wrap_original do |_method, method_name, *_args, &block|
        sequence << method_name
        block&.call
      end
    end

    context "with or without action filter" do
      let(:before_callbacks) do
        klazz.act_before :my_act_before_one
        klazz.act_before :my_act_before_two, action: :create
        klazz.act_before :my_act_before_three
      end
      let(:around_callbacks) do
        klazz.act_around :my_act_around_one
        klazz.act_around :my_act_around_two, action: :create
        klazz.act_around :my_act_around_three
      end
      let(:after_callbacks) do
        klazz.act_after :my_act_after_one
        klazz.act_after :my_act_after_two, action: :create
        klazz.act_after :my_act_after_three
      end

      it "calls in order" do
        klazz_instance.run_act_callbacks(action: :create, format: :html)
        expect(sequence).to eq %i[
          my_act_before_one
          my_act_before_two
          my_act_before_three
          my_act_around_one
          my_act_around_two
          my_act_around_three
          my_act_after_three
          my_act_after_two
          my_act_after_one
        ]
      end
    end

    context "with format filter" do
      let(:before_callbacks) do
        klazz.act_before :my_act_before_one
        klazz.act_before :my_act_before_two, action: :create
        klazz.act_before :my_act_before_three, action: :create, format: :html
        klazz.act_before :my_act_before_four
      end
      let(:around_callbacks) do
        klazz.act_around :my_act_around_one
        klazz.act_around :my_act_around_two, action: :create, format: :html
        klazz.act_around :my_act_around_three, action: :create
        klazz.act_around :my_act_around_four
      end
      let(:after_callbacks) do
        klazz.act_after :my_act_after_one, format: :html
        klazz.act_after :my_act_after_two
        klazz.act_after :my_act_after_three, action: :create
        klazz.act_after :my_act_after_four
      end

      it "calls in order" do
        klazz_instance.run_act_callbacks(action: :create, format: :html)
        expect(sequence).to eq %i[
          my_act_before_one
          my_act_before_two
          my_act_before_three
          my_act_before_four
          my_act_around_one
          my_act_around_two
          my_act_around_three
          my_act_around_four
          my_act_after_four
          my_act_after_three
          my_act_after_two
          my_act_after_one
        ]
      end
    end

    context "with different action/format filters" do
      let(:before_callbacks) do
        klazz.act_before :before_a, action: %i[create show]
        klazz.act_before :before_f, format: %i[json html]
        klazz.act_before :before_anything
      end
      let(:around_callbacks) do
        klazz.act_around :around_a, action: :show
        klazz.act_around :around_f, format: :json
        klazz.act_around :around_anything
      end
      let(:after_callbacks) do
        klazz.act_after :after_a, action: :create
        klazz.act_after :after_f, format: :html
        klazz.act_after :after_a_f, action: :show, format: :json
        klazz.act_after :after_anything
      end

      context "with action name :create" do
        it "calls xml callbacks in order" do
          klazz_instance.run_act_callbacks(action: :create, format: :xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_anything
            after_anything
            after_a
          ]
        end

        it "calls html callbacks in order" do
          klazz_instance.run_act_callbacks(action: :create, format: :html)
          expect(sequence).to eq %i[
            before_a
            before_f
            before_anything
            around_anything
            after_anything
            after_f
            after_a
          ]
        end

        it "calls json callbacks in order" do
          klazz_instance.run_act_callbacks(action: :create, format: :json)
          expect(sequence).to eq %i[
            before_a
            before_f
            before_anything
            around_f
            around_anything
            after_anything
            after_a
          ]
        end
      end

      context "with action name :show" do
        it "calls xml callbacks in order" do
          klazz_instance.run_act_callbacks(action: :show, format: :xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_a
            around_anything
            after_anything
          ]
        end

        it "calls html callbacks in order" do
          klazz_instance.run_act_callbacks(action: :show, format: :html)
          expect(sequence).to eq %i[
            before_a
            before_f
            before_anything
            around_a
            around_anything
            after_anything
            after_f
          ]
        end

        it "calls json callbacks in order" do
          klazz_instance.run_act_callbacks(action: :show, format: :json)
          expect(sequence).to eq %i[
            before_a
            before_f
            before_anything
            around_a
            around_f
            around_anything
            after_anything
            after_a_f
          ]
        end
      end
    end
  end
end
