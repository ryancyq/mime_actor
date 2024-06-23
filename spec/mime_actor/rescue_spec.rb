# frozen_string_literal: true

require "mime_actor"

RSpec.describe MimeActor::Rescue do
  let(:klazz) { Class.new.include described_class }

  describe "#rescue_actor_from" do
    let(:error_class) { StandardError }

    it "requires error filter" do
      expect { klazz.rescue_actor_from }.to raise_error(ArgumentError, "Error filter can't be empty")
    end

    context "with error class" do
      let(:stub_class) { stub_const "MyClass", Class.new }
      let(:stub_module) { stub_const "MyModule", Module.new }
      let(:stub_namespace) { stub_const "OtherModule", Module.new }
      let(:stub_namespace_class) { stub_const "#{stub_namespace}::AnotherClass", Class.new }
      let(:stub_namespace_module) { stub_const "#{stub_namespace}::AnotherModule", Module.new }

      it "accepts Class" do
        expect { klazz.rescue_actor_from stub_class, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyClass", nil, nil, kind_of(Symbol)])
      end

      it "accepts Class with namespace" do
        expect { klazz.rescue_actor_from stub_namespace_class, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherClass", nil, nil, kind_of(Symbol)])
      end

      it "accepts Module" do
        expect { klazz.rescue_actor_from stub_module, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyModule", nil, nil, kind_of(Symbol)])
      end

      it "accepts Module with namespace" do
        expect { klazz.rescue_actor_from stub_namespace_module, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherModule", nil, nil, kind_of(Symbol)])
      end

      it "accepts multiple classes" do
        error_classes = [stub_class, stub_module, stub_namespace_class, stub_namespace_module]
        expect { klazz.rescue_actor_from *error_classes, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(["MyClass", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherClass", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["MyModule", nil, nil, kind_of(Symbol)])
        expect(klazz.actor_rescuers).to include(["OtherModule::AnotherModule", nil, nil, kind_of(Symbol)])
      end
    end

    context "#format" do
      context "with supported format" do
        it "accepts Symbol" do
          expect { klazz.rescue_actor_from error_class, format: :json, with: :my_handler }.not_to raise_error
          expect(klazz.actor_rescuers).to include(
            [error_class.name, :json, nil, kind_of(Symbol)]
          )
        end

        it "accepts arrray of Symbol" do
          expect { klazz.rescue_actor_from error_class, format: [:json, :html], with: :my_handler }.not_to raise_error
          expect(klazz.actor_rescuers).to include(
            [error_class.name, [:json, :html], nil, kind_of(Symbol)]
          )
        end
      end

      context "with unsupported format" do
        it "does not accept" do
          expect { klazz.rescue_actor_from error_class, format: :my_json, with: :my_handler }.to raise_error(
            ArgumentError, "Unsupported format: my_json"
          )
          expect(klazz.actor_rescuers).to be_empty
        end

        it "does not accept in the array" do
          expect { klazz.rescue_actor_from error_class, format: [:json, :my_json, :html, :my_html], with: :my_handler }.to raise_error(
            ArgumentError, "Unsupported formats: my_json, my_html"
          )
          expect(klazz.actor_rescuers).to be_empty
        end
      end
    end

    context "#action" do
      it "accepts Symbol" do
        expect { klazz.rescue_actor_from error_class, action: :index, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error_class.name, nil, :index, kind_of(Symbol)]
        )
      end

      it "accepts array of Symbol" do
        expect { klazz.rescue_actor_from error_class, action: [:debug, :load], with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error_class.name, nil, [:debug, :load], kind_of(Symbol)]
        )
      end
    end

    context "#with" do
      describe "when block is not given" do
        it "is required" do
          expect { klazz.rescue_actor_from error_class }.to raise_error(
            ArgumentError, "Provide the with: keyword argument or a block"
          )
        end
      end

      describe "when block is given" do
        it "must be absent" do
          expect do
            klazz.rescue_actor_from error_class, with: proc {} do
              "test"
            end
          end.to raise_error(ArgumentError, "Provide only the with: keyword argument or a block")
        end
      end
      
      it "accepts Proc" do
        expect { klazz.rescue_actor_from error_class, with: proc {} }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error_class.name, nil, nil, kind_of(Proc)]
        )
      end

      it "accepts Lambda" do
        expect { klazz.rescue_actor_from error_class, with: -> {} }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error_class.name, nil, nil, kind_of(Proc)]
        )
      end

      it "accepts Symbol" do
        expect { klazz.rescue_actor_from error_class, with: :my_handler }.not_to raise_error
        expect(klazz.actor_rescuers).to include(
          [error_class.name, nil, nil, kind_of(Symbol)]
        )
      end

      it "does not accept String" do
        expect { klazz.rescue_actor_from error_class, with: "my handler" }.to raise_error(
          ArgumentError, "Rescue handler can only be Symbol/Proc"
        )
        expect(klazz.actor_rescuers).to be_empty
      end

      it "does not accept Method" do
        expect { klazz.rescue_actor_from error_class, with: method(:to_s) }.to raise_error(
          ArgumentError, "Rescue handler can only be Symbol/Proc"
        )
        expect(klazz.actor_rescuers).to be_empty
      end
    end
  end

  describe "#rescue_actor" do
    let(:error_class) { RuntimeError }
    let(:error) { error_class.new("my error") }

    context "with empty actor_rescuers" do
      subject { klazz.rescue_actor(error) }

      it { is_expected.to be_nil }
    end

    context "with non matching actor_rescuers" do
      subject { klazz.rescue_actor(error) }

      before do
        klazz.rescue_actor_from ArgumentError, with: proc {}
        klazz.rescue_actor_from NameError, with: proc {}
      end

      it { is_expected.to be_nil }
    end

    context "with matching actor_rescuers" do
      let(:resolve) { klazz.rescue_actor(error) }

      it "resolves error matching actor_rescuer" do
        klazz.rescue_actor_from error_class, with: proc { @stub_value = 1 }
        expect(resolve).to eq error
        expect(klazz.instance_variable_get(:@stub_value)).to eq 1
      end

      context "with multiple rescuers on the same error" do
        before do
          klazz.rescue_actor_from error_class, with: proc { @stub_value = 1 }
          klazz.rescue_actor_from error_class, with: proc { @stub_value = 2 }
          klazz.rescue_actor_from error_class, with: proc { @stub_value = 3 }
        end

        it "resolves using most recently delcared actor_rescuer" do
          expect(resolve).to eq error
          expect(klazz.instance_variable_get(:@stub_value)).to eq 3
        end
      end

      context "with action filter" do
        let(:error_class) { stub_const "MyActionError", Class.new(StandardError) }

        before do
          klazz.rescue_actor_from StandardError, action: :create, with: proc { @stub_value = 1 }
          klazz.rescue_actor_from error_class, action: :index, with: proc { @stub_value = 2 }
        end

        it "resolves with action matching actor_rescuer" do
          expect(klazz.rescue_actor(error, action: :create)).to eq error
          expect(klazz.instance_variable_get(:@stub_value)).to eq 1
        end
      end

      context "with format filter" do
        let(:error_class) { stub_const "MyFormatError", Class.new(StandardError) }

        before do
          klazz.rescue_actor_from StandardError, format: :json, with: proc { @stub_value = 1 }
          klazz.rescue_actor_from error_class, format: :html, with: proc { @stub_value = 2 }
        end

        it "resolves with format matching actor_rescuer" do
          expect(klazz.rescue_actor(error, format: :json)).to eq error
          expect(klazz.instance_variable_get(:@stub_value)).to eq 1
        end
      end

      context "with action and format filters" do
        let(:error_class) { stub_const "MyError", Class.new(StandardError) }

        before do
          klazz.rescue_actor_from StandardError, with: proc { @stub_value = 1 }
          klazz.rescue_actor_from error_class, action: :create, format: :json, with: proc { @stub_value = 2 }
          klazz.rescue_actor_from error_class, format: :html, with: proc { @stub_value = 3 }
          klazz.rescue_actor_from StandardError, action: :index, format: :html, with: proc { @stub_value = 4 }
        end

        it "resolves with action and format matching actor_rescuer" do
          expect(klazz.rescue_actor(error, action: :create, format: :json)).to eq error
          expect(klazz.instance_variable_get(:@stub_value)).to eq 2
        end

        it "resolves with error matching actor_rescuer as fallback" do
          expect(klazz.rescue_actor(error, action: :index, format: :json)).to eq error
          expect(klazz.instance_variable_get(:@stub_value)).to eq 1
        end
      end
    end

    describe "#visited" do
      it "skips actor_rescuer who rescues error appeared in visited" do
        expect(klazz.rescue_actor(error, visited: [error_class])).to be_nil
      end
    end

    context "with nested error" do
      let(:resolve) { klazz.rescue_actor(error) }
      let(:error_class) { stub_const "MyError", Class.new(RuntimeError) }

      before do
        klazz.rescue_actor_from RuntimeError, with: proc {}
      end

      it "resolves correctly" do
        expect(resolve).to eq error
      end
    end
  end
end