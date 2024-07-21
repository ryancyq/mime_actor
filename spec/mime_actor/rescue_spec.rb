# frozen_string_literal: true

require "mime_actor/rescue"

RSpec.describe MimeActor::Rescue do
  let(:klazz) { Class.new.include described_class }

  describe "#rescue_act_from" do
    describe "error filter" do
      let(:stub_namespace) { stub_const "OtherModule", Module.new }

      it "required" do
        expect { klazz.rescue_act_from }.to raise_error(ArgumentError, "error filter is required")
      end

      it_behaves_like "rescuable error filter", "Class" do
        let(:error_filter) { stub_const "MyClass", Class.new }
      end
      it_behaves_like "rescuable error filter", "Module" do
        let(:error_filter) { stub_const "MyModule", Module.new }
      end
      it_behaves_like "rescuable error filter", "Class with namespace" do
        let(:error_filter) { stub_const "#{stub_namespace}::AnotherClass", Class.new }
      end
      it_behaves_like "rescuable error filter", "Module with namespace" do
        let(:error_filter) { stub_const "#{stub_namespace}::AnotherModule", Module.new }
      end
      it_behaves_like "rescuable error filter", "Multiple errors" do
        let(:error_filters) do
          [
            stub_const("MyClass", Class.new),
            stub_const("MyModule", Module.new),
            stub_const("OtherModule", Module.new),
            stub_const("#{stub_namespace}::AnotherClass", Class.new),
            stub_const("#{stub_namespace}::AnotherModule", Module.new)
          ]
        end
      end
      it_behaves_like "rescuable error filter", "String" do
        let(:error_filter) { "Object" }
      end
      it_behaves_like "rescuable error filter", "Integer", acceptance: false do
        let(:error_filter) { 100 }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "100 must be a Class/Module or a String referencing a Class/Module" }
      end
    end

    describe "#format" do
      describe "supported format" do
        it_behaves_like "rescuable format filter", "Symbol" do
          let(:format_filter) { :json }
        end
        it_behaves_like "rescuable format filter", "Array of Symbol" do
          let(:format_filters) { %i[json html] }
        end
        it_behaves_like "rescuable format filter", "String", acceptance: false do
          let(:format_filter) { "json" }
          let(:error_class_raised) { TypeError }
          let(:error_message_raised) { "format must be a Symbol" }
        end
        it_behaves_like "rescuable format filter", "Array of String", acceptance: false do
          let(:format_filters) { %w[json html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: \"json\", \"html\"" }
        end
        it_behaves_like "rescuable format filter", "Array of Symbol/String", acceptance: false do
          let(:format_filters) { [:json, "html"] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: \"html\"" }
        end
      end

      describe "unsupported format" do
        it_behaves_like "rescuable format filter", "Symbol", acceptance: false do
          let(:format_filter) { :my_json }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid format, got: :my_json" }
        end
        it_behaves_like "rescuable format filter", "Array of Symbol", acceptance: false do
          let(:format_filters) { %i[json my_json html my_html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: :my_json, :my_html" }
        end
        it_behaves_like "rescuable format filter", "String", acceptance: false do
          let(:format_filter) { "my_json" }
          let(:error_class_raised) { TypeError }
          let(:error_message_raised) { "format must be a Symbol" }
        end
        it_behaves_like "rescuable format filter", "Array of String", acceptance: false do
          let(:format_filters) { %w[json my_json html my_html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: \"json\", \"my_json\", \"html\", \"my_html\"" }
        end
        it_behaves_like "rescuable format filter", "Array of Symbol/String", acceptance: false do
          let(:format_filters) { [:json, :my_json, "html", "my_html"] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: :my_json, \"html\", \"my_html\"" }
        end
      end
    end

    describe "#action" do
      it_behaves_like "rescuable action filter", "Symbol" do
        let(:action_filter) { :index }
      end
      it_behaves_like "rescuable action filter", "Array of Symbol" do
        let(:action_filters) { %i[debug load] }
      end
      it_behaves_like "rescuable action filter", "String", acceptance: false do
        let(:action_filter) { "index" }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "action must be a Symbol" }
      end
      it_behaves_like "rescuable action filter", "Array of String", acceptance: false do
        let(:action_filters) { %w[debug load] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: \"debug\", \"load\"" }
      end
    end

    describe "#with" do
      describe "when block is not given" do
        let(:rescue_act) { klazz.rescue_act_from StandardError }

        it "required" do
          expect { rescue_act }.to raise_error(ArgumentError, "provide either the with: argument or a block")
        end
      end

      describe "when block is given" do
        let(:rescue_act) do
          klazz.rescue_act_from StandardError, with: proc {} do
            "test"
          end
        end

        it "must be absent" do
          expect { rescue_act }.to raise_error(ArgumentError, "provide either the with: argument or a block")
        end
      end

      it_behaves_like "rescuable with handler", "Proc", Proc do
        let(:handler) { proc {} }
      end
      it_behaves_like "rescuable with handler", "Lambda", Proc do
        let(:handler) { -> {} }
      end
      it_behaves_like "rescuable with handler", "Symbol", Symbol do
        let(:handler) { :custom_handler }
      end
      it_behaves_like "rescuable with handler", "String", String, acceptance: false do
        let(:handler) { "custom_handler" }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "with handler must be a Symbol or Proc, got: #{handler.inspect}" }
      end
      it_behaves_like "rescuable with handler", "Method", Method, acceptance: false do
        let(:handler) { method(:to_s) }
        let(:error_class_raised) { TypeError }
        let(:error_message_raised) { "with handler must be a Symbol or Proc, got: #{handler.inspect}" }
      end
    end

    describe "#block" do
      let(:rescue_act) do
        klazz.rescue_act_from StandardError do
          "test"
        end
      end

      it "be the handler" do
        expect(klazz.actor_rescuers).to be_empty
        expect { rescue_act }.not_to raise_error
        expect(klazz.actor_rescuers).not_to be_empty
        expect(klazz.actor_rescuers).to include(["StandardError", nil, nil, kind_of(Proc)])
      end
    end
  end

  describe "#self.rescue_actor" do
    let(:error_class) { RuntimeError }

    context "with deprecation" do
      include_context "with rescuable actor handler class method"
      it "logs deprecation warning" do
        expect { rescuable }.to have_deprecated(
          %r{rescue_actor is deprecated .*use #rescue_actor instance method}
        )
      end
    end

    it_behaves_like "rescuable actor handler class method", "emtpy actor_rescuers", acceptance: false

    it_behaves_like "rescuable actor handler class method", "non-matching actor_rescuers", acceptance: false do
      before do
        klazz.rescue_act_from ArgumentError, with: proc {}
        klazz.rescue_act_from NameError, with: proc {}
      end
    end

    it_behaves_like "rescuable actor handler class method", "defined class name" do
      before { klazz.rescue_act_from "RuntimeError", with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "defined class name with namespace" do
      let(:error_class) { MimeActor::Error }
      before { klazz.rescue_act_from "MimeActor::Error", with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "undefined class name", acceptance: false do
      before { klazz.rescue_act_from "MyError", with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "error subclass" do
      let(:error_class) { stub_const "MyError", Class.new(RuntimeError) }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "method actor_rescuer" do
      before do
        rescue_context_class.define_method(:method_actor_rescuer) { |ex| equal?(ex) }
        klazz.rescue_act_from RuntimeError, with: :method_actor_rescuer
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "proc actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: proc { |ex| equal?(ex) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "lambda actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: ->(ex) { equal?(ex) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "error matching actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: -> { equal?(1) }
        klazz.rescue_act_from ArgumentError, with: -> { equal?(2) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "action matching actor_rescuer" do
      let(:action_filter) { :create }

      before do
        klazz.rescue_act_from RuntimeError, action: :create, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, action: :index, with: -> { equal?(2) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "format matching actor_rescuer" do
      let(:format_filter) { :json }

      before do
        klazz.rescue_act_from RuntimeError, format: :xml, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, format: :json, with: -> { equal?(2) }
        klazz.rescue_act_from RuntimeError, format: :html, with: -> { equal?(3) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(2).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "error in visited", acceptance: false do
      let(:visited_errors) { [error_instance] }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "error re-raised" do
      let(:error_re_raise) do
        begin
          raise "my original error"
        rescue StandardError
          raise ArgumentError, "my re-raised error"
        end
      rescue StandardError => e
        e
      end
      let(:error_instance) { error_re_raise }
      let(:error_instance_rescued) { error_re_raise.cause }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler class method", "action and format matching actor_rescuers" do
      let(:error_class) { stub_const "MyError", Class.new(StandardError) }
      let(:rescue_context) { Object.new }
      let(:action_filter) { :create }
      let(:format_filter) { :json }

      before do
        klazz.rescue_act_from StandardError, with: proc { equal?(1) }
        klazz.rescue_act_from error_class, action: :create, format: :json, with: proc { equal?(2) }
        klazz.rescue_act_from error_class, format: :html, with: proc { equal?(3) }
        klazz.rescue_act_from StandardError, action: :index, format: :html, with: proc { equal?(4) }
      end

      it "rescues with handler context" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(2).once
      end

      it "rescues with fallback" do
        allow(rescue_context).to receive(:equal?)
        expect do
          klazz.rescue_actor(error_instance, action: :index, format: :json, context: rescue_context)
        end.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler class method", "multiple matching actor_rescuers" do
      let(:rescue_context) { Object.new }

      before do
        klazz.rescue_act_from RuntimeError, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, with: -> { equal?(2) }
        klazz.rescue_act_from RuntimeError, with: -> { equal?(3) }
      end

      it "rescues using most recently declared actor_rescuer" do
        allow(rescue_context).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(rescue_context).to have_received(:equal?).with(3).once
      end
    end

    context "when rescuee is not string and symbol" do
      include_context "with rescuable actor handler class method"

      before do
        klazz.actor_rescuers << [123, nil, nil, proc {}]
      end

      it "raise #{TypeError}" do
        expect { rescuable }.to raise_error(TypeError, "class or module required")
      end
    end
  end

  describe "#rescue_actor" do
    let(:error_class) { RuntimeError }

    it_behaves_like "rescuable actor handler", "emtpy actor_rescuers", acceptance: false

    it_behaves_like "rescuable actor handler", "non-matching actor_rescuers", acceptance: false do
      before do
        klazz.rescue_act_from ArgumentError, with: proc {}
        klazz.rescue_act_from NameError, with: proc {}
      end
    end

    it_behaves_like "rescuable actor handler", "defined class name" do
      before { klazz.rescue_act_from "RuntimeError", with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "defined class name with namespace" do
      let(:error_class) { MimeActor::Error }
      before { klazz.rescue_act_from "MimeActor::Error", with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "undefined class name", acceptance: false do
      before { klazz.rescue_act_from "MyError", with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "error subclass" do
      let(:error_class) { stub_const "MyError", Class.new(RuntimeError) }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "method actor_rescuer" do
      before do
        klazz.define_method(:method_actor_rescuer) { |ex| equal?(ex) }
        klazz.rescue_act_from RuntimeError, with: :method_actor_rescuer
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler", "proc actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: proc { |ex| equal?(ex) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler", "lambda actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: ->(ex) { equal?(ex) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(error_instance).once
      end
    end

    it_behaves_like "rescuable actor handler", "error matching actor_rescuer" do
      before do
        klazz.rescue_act_from RuntimeError, with: -> { equal?(1) }
        klazz.rescue_act_from ArgumentError, with: -> { equal?(2) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler", "action matching actor_rescuer" do
      let(:action_filter) { :create }

      before do
        klazz.rescue_act_from RuntimeError, action: :create, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, action: :index, with: -> { equal?(2) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler", "format matching actor_rescuer" do
      let(:format_filter) { :json }

      before do
        klazz.rescue_act_from RuntimeError, format: :xml, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, format: :json, with: -> { equal?(2) }
        klazz.rescue_act_from RuntimeError, format: :html, with: -> { equal?(3) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(2).once
      end
    end

    it_behaves_like "rescuable actor handler", "error in visited", acceptance: false do
      let(:visited_errors) { [error_instance] }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "error re-raised" do
      let(:error_re_raise) do
        begin
          raise "my original error"
        rescue StandardError
          raise ArgumentError, "my re-raised error"
        end
      rescue StandardError => e
        e
      end
      let(:error_instance) { error_re_raise }
      let(:error_instance_rescued) { error_re_raise.cause }
      before { klazz.rescue_act_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler", "action and format matching actor_rescuers" do
      let(:error_class) { stub_const "MyError", Class.new(StandardError) }
      let(:action_filter) { :create }
      let(:format_filter) { :json }

      before do
        klazz.rescue_act_from StandardError, with: proc { equal?(1) }
        klazz.rescue_act_from error_class, action: :create, format: :json, with: proc { equal?(2) }
        klazz.rescue_act_from error_class, format: :html, with: proc { equal?(3) }
        klazz.rescue_act_from StandardError, action: :index, format: :html, with: proc { equal?(4) }
      end

      it "rescues with handler context" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(2).once
      end

      it "rescues with fallback" do
        allow(klazz_instance).to receive(:equal?)
        expect do
          klazz_instance.rescue_actor(error_instance, action: :index, format: :json)
        end.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(1).once
      end
    end

    it_behaves_like "rescuable actor handler", "multiple matching actor_rescuers" do
      before do
        klazz.rescue_act_from RuntimeError, with: -> { equal?(1) }
        klazz.rescue_act_from RuntimeError, with: -> { equal?(2) }
        klazz.rescue_act_from RuntimeError, with: -> { equal?(3) }
      end

      it "rescues using most recently declared actor_rescuer" do
        allow(klazz_instance).to receive(:equal?)
        expect { rescuable }.not_to raise_error
        expect(klazz_instance).to have_received(:equal?).with(3).once
      end
    end

    context "when rescuee is not string and symbol" do
      include_context "with rescuable actor handler"

      before do
        klazz.actor_rescuers << [123, nil, nil, proc {}]
      end

      it "raise #{TypeError}" do
        expect { rescuable }.to raise_error(TypeError, "class or module required")
      end
    end
  end
end
