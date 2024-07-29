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

      klazz.define_method(:action_name) { "placeholder" }
      klazz.define_method(:method_missing) { |*_args| "missed" }
      klazz.define_method(:respond_to_missing?) { |*_args| "responded" }

      allow(klazz_instance).to receive(:action_name).and_return(act_action.to_s)
      allow(klazz_instance).to receive(:method_missing).and_wrap_original do |_method, method_name, *_args, &block|
        sequence << method_name
        block&.call
      end
    end

    context "with or without action filter" do
      let(:act_action) { :create }
      let(:before_callbacks) do
        klazz.before_act :my_before_act_one
        klazz.before_act :my_before_act_two, action: :create
        klazz.before_act :my_before_act_three
      end
      let(:around_callbacks) do
        klazz.around_act :my_around_act_one
        klazz.around_act :my_around_act_two, action: :create
        klazz.around_act :my_around_act_three
      end
      let(:after_callbacks) do
        klazz.after_act :my_after_act_one
        klazz.after_act :my_after_act_two, action: :create
        klazz.after_act :my_after_act_three
      end

      it "calls in order" do
        klazz_instance.run_act_callbacks(:html)
        expect(sequence).to eq %i[
          my_before_act_one
          my_before_act_two
          my_before_act_three
          my_around_act_one
          my_around_act_two
          my_around_act_three
          my_after_act_three
          my_after_act_two
          my_after_act_one
        ]
      end
    end

    context "with format filter" do
      let(:act_action) { :create }
      let(:before_callbacks) do
        klazz.before_act :my_before_act_one
        klazz.before_act :my_before_act_two, action: :create
        klazz.before_act :my_before_act_three, action: :create, format: :html
        klazz.before_act :my_before_act_four
      end
      let(:around_callbacks) do
        klazz.around_act :my_around_act_one
        klazz.around_act :my_around_act_two, action: :create, format: :html
        klazz.around_act :my_around_act_three, action: :create
        klazz.around_act :my_around_act_four
      end
      let(:after_callbacks) do
        klazz.after_act :my_after_act_one, format: :html
        klazz.after_act :my_after_act_two
        klazz.after_act :my_after_act_three, action: :create
        klazz.after_act :my_after_act_four
      end

      it "calls in order" do
        klazz_instance.run_act_callbacks(:html)
        expect(sequence).to eq %i[
          my_before_act_one
          my_before_act_two
          my_before_act_four
          my_around_act_one
          my_around_act_three
          my_around_act_four
          my_before_act_three
          my_around_act_two
          my_after_act_one
          my_after_act_four
          my_after_act_three
          my_after_act_two
        ]
      end
    end

    context "with different action/format filters" do
      let(:before_callbacks) do
        klazz.before_act :before_a, action: %i[create show]
        klazz.before_act :before_f, format: %i[json html]
        klazz.before_act :before_anything
      end
      let(:around_callbacks) do
        klazz.around_act :around_a, action: :show
        klazz.around_act :around_f, format: :json
        klazz.around_act :around_anything
      end
      let(:after_callbacks) do
        klazz.after_act :after_a, action: :create
        klazz.after_act :after_f, format: :html
        klazz.after_act :after_a_f, action: :show, format: :json
        klazz.after_act :after_anything
      end

      context "with action name :create" do
        let(:act_action) { :create }

        it "calls xml callbacks in order" do
          klazz_instance.run_act_callbacks(:xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_anything
            after_anything
            after_a
          ]
        end

        it "calls html callbacks in order" do
          klazz_instance.run_act_callbacks(:html)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_anything
            before_f
            after_f
            after_anything
            after_a
          ]
        end

        it "calls json callbacks in order" do
          klazz_instance.run_act_callbacks(:json)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_anything
            before_f
            around_f
            after_anything
            after_a
          ]
        end
      end

      context "with action name :show" do
        let(:act_action) { :show }

        it "calls xml callbacks in order" do
          klazz_instance.run_act_callbacks(:xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_a
            around_anything
            after_anything
          ]
        end

        it "calls html callbacks in order" do
          klazz_instance.run_act_callbacks(:html)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_a
            around_anything
            before_f
            after_f
            after_anything
          ]
        end

        it "calls json callbacks in order" do
          klazz_instance.run_act_callbacks(:json)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_a
            around_anything
            before_f
            around_f
            after_a_f
            after_anything
          ]
        end
      end
    end
  end
end
