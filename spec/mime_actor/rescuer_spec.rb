# frozen_string_literal: true

require "action_controller"
require "mime_actor"

RSpec.describe MimeActor::Rescuer do
  let(:klazz) { Class.new(ActionController::Metal).include described_class }

  describe "#rescue_act_from" do
    let(:error) { StandardError }

    context "with error class" do
      let(:stub_class) { class MyClass; end; MyClass }
      let(:stub_module) { module MyModule end; MyModule }
      let(:stub_namespace_class) do
        module OtherModule
          class AnotherClass; end
        end
        OtherModule::AnotherClass
      end
      let(:stub_namespace_module) do
        module OtherModule
          module AnotherModule; end
        end
        OtherModule::AnotherModule
      end

      it "accepts Class" do
        expect { klazz.rescue_act_from stub_class, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyClass", nil, nil, kind_of(Symbol)])
      end

      it "accepts Class with namespace" do
        expect { klazz.rescue_act_from stub_namespace_class, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherClass", nil, nil, kind_of(Symbol)])
      end

      it "accepts Module" do
        expect { klazz.rescue_act_from stub_module, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyModule", nil, nil, kind_of(Symbol)])
      end

      it "accepts Module with namespace" do
        expect { klazz.rescue_act_from stub_namespace_module, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherModule", nil, nil, kind_of(Symbol)])
      end

      it "accepts multiple classes" do
        error_classes = [stub_class, stub_module, stub_namespace_class, stub_namespace_module]
        expect { klazz.rescue_act_from *error_classes, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyClass", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherClass", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["MyModule", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherModule", nil, nil, kind_of(Symbol)])
      end
    end

    context "#format" do
      context "with supported format" do
        it "accepts Symbol" do
          expect { klazz.rescue_act_from error, format: :json, with: :my_handler }.not_to raise_error
          expect(klazz.actor_rescuers).to include(
            [error.name, :json, nil, kind_of(Symbol)]
          )
        end

        it "accepts arrray of Symbol" do
          expect { klazz.rescue_act_from error, format: [:json, :html], with: :my_handler }.not_to raise_error
          expect(klazz.actor_rescuers).to include(
            [error.name, [:json, :html], nil, kind_of(Symbol)]
          )
        end
      end

      context "with unsupported format" do
        it "does not accept" do
          expect { klazz.rescue_act_from error, format: :my_json, with: :my_handler }.to raise_error(
            ArgumentError, "Unsupported format: my_json"
          )
          expect(klazz.actor_rescuers).to be_empty
        end

        it "does not accept in the array" do
          expect { klazz.rescue_act_from error, format: [:json, :my_json, :html, :my_html], with: :my_handler }.to raise_error(
            ArgumentError, "Unsupported formats: my_json, my_html"
          )
          expect(klazz.actor_rescuers).to be_empty
        end
      end
    end

    context "#action" do
      it "accepts Symbol" do
        expect { klazz.rescue_act_from error, action: :index, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error.name, nil, :index, kind_of(Symbol)]
        )
      end

      it "accepts array of Symbol" do
        expect { klazz.rescue_act_from error, action: [:debug, :load], with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error.name, nil, [:debug, :load], kind_of(Symbol)]
        )
      end
    end

    context "#with" do
      it "accepts Proc" do
        expect { klazz.rescue_act_from error, with: proc {} }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error.name, nil, nil, kind_of(Proc)]
        )
      end

      it "accepts Lambda" do
        expect { klazz.rescue_act_from error, with: -> {} }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error.name, nil, nil, kind_of(Proc)]
        )
      end

      it "accepts Symbol" do
        expect { klazz.rescue_act_from error, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error.name, nil, nil, kind_of(Symbol)]
        )
      end

      it "does not accept String" do
        expect { klazz.rescue_act_from error, with: "my handler" }.to raise_error(
          ArgumentError, "Rescue handler can only be Symbol/Proc"
        )
        expect(klazz.actor_rescuers).to be_empty
      end

      it "does not accept Method" do
        expect { klazz.rescue_act_from error, with: method(:to_s) }.to raise_error(
          ArgumentError, "Rescue handler can only be Symbol/Proc"
        )
        expect(klazz.actor_rescuers).to be_empty
      end
    end
  end
end