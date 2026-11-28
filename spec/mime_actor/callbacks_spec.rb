# frozen_string_literal: true

require "action_view/testing/resolvers"

require "mime_actor"

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
    include_context "with a mime_actor controller"
    let(:sequence) { [] }

    before do
      before_callbacks
      around_callbacks
      after_callbacks

      recorded = sequence
      klazz.__callbacks[:act].map(&:filter).grep(Symbol).each do |name|
        klazz.define_method(name) do |&block|
          recorded << name
          block&.call
        end
      end
      klazz.act_on_action :create, :show, format: %i[xml html json], with: -> { head :ok }
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
        dispatch(klazz_instance, :create, :html)
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
        dispatch(klazz_instance, :create, :html)
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
          dispatch(klazz_instance, :create, :xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_anything
            after_anything
            after_a
          ]
        end

        it "calls html callbacks in order" do
          dispatch(klazz_instance, :create, :html)
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
          dispatch(klazz_instance, :create, :json)
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
          dispatch(klazz_instance, :show, :xml)
          expect(sequence).to eq %i[
            before_a
            before_anything
            around_a
            around_anything
            after_anything
          ]
        end

        it "calls html callbacks in order" do
          dispatch(klazz_instance, :show, :html)
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
          dispatch(klazz_instance, :show, :json)
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

  describe "halting" do
    include_context "with a mime_actor controller"

    let(:events) { [] }

    before do
      recorded = events
      klazz.act_before -> { recorded << :first_before }
      klazz.act_before :respond_early
      klazz.act_before -> { recorded << :later_before }
      klazz.act_around :around_act
      klazz.define_method(:around_act) do |&block|
        recorded << :around
        block.call
      end
      klazz.act_after -> { recorded << :after }
      klazz.act_on_action :create, format: :html, with: -> { recorded << :act }
    end

    {
      "redirects" => [302, -> { redirect_to "/events" }],
      "renders"   => [200, -> { render plain: "early" }],
      "heads"     => [202, -> { head :accepted }]
    }.each do |description, (expected_status, respond)|
      [ActionController::Base, ActionController::API].each do |base|
        context "when an act_before #{description} on #{base}" do
          let(:controller_base) { base }

          before { klazz.define_method(:respond_early, &respond) }

          it "skips the later callbacks and the act" do
            expect(dispatch(klazz, :create).first).to eq expected_status
            expect(events).to eq [:first_before]
          end
        end
      end
    end

    context "when an act_before responds on #{ActionController::Metal}" do
      let(:controller_base) { ActionController::Metal }

      before { klazz.define_method(:respond_early) { self.response_body = "early" } }

      it "skips the later callbacks and the act" do
        expect(dispatch(klazz, :create).last.body).to eq "early"
        expect(events).to eq [:first_before]
      end
    end

    context "when an act_before throws :abort" do
      before { klazz.define_method(:respond_early) { throw :abort } }

      it "skips the later callbacks and the act" do
        expect(dispatch(klazz, :create).first).to eq 204
        expect(events).to eq [:first_before]
      end

      it "still renders the template of the action by default" do
        klazz.define_singleton_method(:controller_path) { "events" }
        klazz.view_paths = [ActionView::FixtureResolver.new("events/create.html.erb" => "event: <%= @event.inspect %>")]
        klazz.act_on_action :create, format: :html, with: -> { @event = "created" }

        expect(dispatch(klazz, :create).last.body).to eq "event: nil"
        expect(events).to eq [:first_before]
      end
    end

    context "when an act_around does not yield" do
      before do
        recorded = events
        klazz.define_method(:respond_early) { nil }
        klazz.act_around ->(_, _block) { recorded << :blocking_around }
      end

      it "skips the act, like ActiveSupport::Callbacks the act_after still runs" do
        expect(dispatch(klazz, :create).first).to eq 204
        expect(events).to eq %i[first_before later_before around blocking_around after]
      end
    end

    context "when no act_before responds" do
      before { klazz.define_method(:respond_early) { nil } }

      it "runs the act and the act_after" do
        expect(dispatch(klazz, :create).first).to eq 204
        expect(events).to eq %i[first_before later_before around act after]
      end
    end
  end
end
