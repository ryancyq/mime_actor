# frozen_string_literal: true

require "mime_actor/rescue"

RSpec.describe MimeActor::Rescue do
  let(:klazz) { Class.new.include described_class }

  describe "#rescue_actor_from" do
    describe "error filter" do
      let(:stub_namespace) { stub_const "OtherModule", Module.new }

      it "required" do
        expect { klazz.rescue_actor_from }.to raise_error(ArgumentError, "error filter is required")
      end

      it_behaves_like "rescuable error filter accepted", "Class" do
        let(:error_filter) { stub_const "MyClass", Class.new }
      end
      it_behaves_like "rescuable error filter accepted", "Module" do
        let(:error_filter) { stub_const "MyModule", Module.new }
      end
      it_behaves_like "rescuable error filter accepted", "Class with namespace" do
        let(:error_filter) { stub_const "#{stub_namespace}::AnotherClass", Class.new }
      end
      it_behaves_like "rescuable error filter accepted", "Module with namespace" do
        let(:error_filter) { stub_const "#{stub_namespace}::AnotherModule", Module.new }
      end
      it_behaves_like "rescuable error filter accepted", "Multiple errors" do
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
    end

    describe "#format" do
      describe "supported format" do
        it_behaves_like "rescuable format filter accepted", "Symbol" do
          let(:format_filter) { :json }
        end
        it_behaves_like "rescuable format filter accepted", "Array of Symbol" do
          let(:format_filters) { %i[json html] }
        end
        it_behaves_like "rescuable format filter rejected", "String" do
          let(:format_filter) { "json" }
        end
        it_behaves_like "rescuable format filter rejected", "Array of String" do
          let(:format_filters) { %w[json html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: json, html" }
        end
        it_behaves_like "rescuable format filter rejected", "Array of Symbol/String" do
          let(:format_filters) { [:json, "html"] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: html" }
        end
      end

      describe "unsupported format" do
        it_behaves_like "rescuable format filter rejected", "Symbol" do
          let(:format_filter) { :my_json }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid format, got: my_json" }
        end
        it_behaves_like "rescuable format filter rejected", "Array of Symbol" do
          let(:format_filters) { %i[json my_json html my_html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: my_json, my_html" }
        end
        it_behaves_like "rescuable format filter rejected", "String" do
          let(:format_filter) { "my_json" }
        end
        it_behaves_like "rescuable format filter rejected", "Array of String" do
          let(:format_filters) { %w[json my_json html my_html] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: json, my_json, html, my_html" }
        end
        it_behaves_like "rescuable format filter rejected", "Array of Symbol/String" do
          let(:format_filters) { [:json, :my_json, "html", "my_html"] }
          let(:error_class_raised) { NameError }
          let(:error_message_raised) { "invalid formats, got: my_json, html, my_html" }
        end
      end
    end

    describe "#action" do
      it_behaves_like "rescuable action filter accepted", "Symbol" do
        let(:action_filter) { :index }
      end
      it_behaves_like "rescuable action filter accepted", "Array of Symbol" do
        let(:action_filters) { %i[debug load] }
      end
      it_behaves_like "rescuable action filter rejected", "String" do
        let(:action_filter) { "index" }
      end
      it_behaves_like "rescuable action filter rejected", "Array of String" do
        let(:action_filters) { %w[debug load] }
        let(:error_class_raised) { NameError }
        let(:error_message_raised) { "invalid actions, got: debug, load" }
      end
    end

    describe "#with" do
      describe "when block is not given" do
        let(:rescue_actor) { klazz.rescue_actor_from StandardError }

        it "required" do
          expect { rescue_actor }.to raise_error(ArgumentError, "provide the with: keyword argument or a block")
        end
      end

      describe "when block is given" do
        let(:rescue_actor) do
          klazz.rescue_actor_from StandardError, with: proc {} do
            "test"
          end
        end

        it "must be absent" do
          expect { rescue_actor }.to raise_error(ArgumentError, "provide either the with: keyword argument or a block")
        end
      end

      it_behaves_like "rescuable with handler accepted", "Proc", Proc do
        let(:handler) { proc {} }
      end
      it_behaves_like "rescuable with handler accepted", "Lambda", Proc do
        let(:handler) { -> {} }
      end
      it_behaves_like "rescuable with handler accepted", "Symbol", Symbol do
        let(:handler) { :custom_handler }
      end
      it_behaves_like "rescuable with handler rejected", "String", String do
        let(:handler) { "custom_handler" }
      end
      it_behaves_like "rescuable with handler rejected", "Method", Method do
        let(:handler) { method(:to_s) }
      end
    end
  end

  describe "#rescue_actor" do
    let(:error_class) { RuntimeError }

    it_behaves_like "rescuable actor handler skipped", "emtpy actor_rescuers"
    it_behaves_like "rescuable actor handler skipped", "non-matching actor_rescuers" do
      before do
        klazz.rescue_actor_from ArgumentError, with: proc {}
        klazz.rescue_actor_from NameError, with: proc {}
      end
    end

    it_behaves_like "rescuable actor handler rescued", "error subclass" do
      let(:error_class) { stub_const "MyError", Class.new(RuntimeError) }
      before { klazz.rescue_actor_from RuntimeError, with: proc {} }
    end
    it_behaves_like "rescuable actor handler rescued", "error matching actor_rescuer" do
      before do
        klazz.rescue_actor_from RuntimeError, with: -> { to_s + "1" }
        klazz.rescue_actor_from ArgumentError, with: -> { to_s + "2" }
      end

      xit "recues with handler context" do
        expect { rescuable }.not_to raise_error
      end
    end
    it_behaves_like "rescuable actor handler rescued", "action matching actor_rescuer" do
      let(:action_filter) { :create }
      before do
        klazz.rescue_actor_from RuntimeError, action: :create, with: -> { to_s + "1" }
        klazz.rescue_actor_from RuntimeError, action: :index, with: -> { to_s + "2" }
      end

      xit "recues with handler context" do
        expect { rescuable }.not_to raise_error
      end
    end
    it_behaves_like "rescuable actor handler rescued", "format matching actor_rescuer" do
      let(:format_filter) { :json }
      before do
        klazz.rescue_actor_from RuntimeError, format: :xml, with: -> { to_s + "1" }
        klazz.rescue_actor_from RuntimeError, format: :json, with: -> { to_s + "2" }
        klazz.rescue_actor_from RuntimeError, format: :html, with: -> { to_s + "3" }
      end

      xit "recues with handler context" do
        expect { rescuable }.not_to raise_error
      end
    end
    it_behaves_like "rescuable actor handler skipped", "error in visited" do
      let(:visited_errors) { [error_instance] }
      before { klazz.rescue_actor_from RuntimeError, with: proc {} }
    end

    it_behaves_like "rescuable actor handler rescued", "action and format matching actor_rescuers" do
      let(:error_class) { stub_const "MyError", Class.new(StandardError) }

      before { 
        klazz.rescue_actor_from StandardError, with: proc { to_s + "1" }
        klazz.rescue_actor_from error_class, action: :create, format: :json, with: proc { to_s + "2"}
        klazz.rescue_actor_from error_class, format: :html, with: proc { to_s + "3" }
        klazz.rescue_actor_from StandardError, action: :index, format: :html, with: proc { to_s + "4" }
      }

      xit "recues with handler context" do
        expect(klazz.rescue_actor(error, action: :create, format: :json)).to eq error
      end

      xit "recues with error matching actor_rescuer as fallback" do
        expect(klazz.rescue_actor(error, action: :index, format: :json)).to eq error
      end
    end

    it_behaves_like "rescuable actor handler rescued", "multiple matching actor_rescuers" do
      before { 
        klazz.rescue_actor_from RuntimeError, with: -> { to_s + "1" }
        klazz.rescue_actor_from RuntimeError, with: -> { to_s + "2" }
        klazz.rescue_actor_from RuntimeError, with: -> { to_s + "3" }
      }

      xit "recues using most recently declared actor_rescuer" do
        expect { rescuable }.not_to raise_error
      end
    end
  end
end
