# frozen_string_literal: true

require "mime_actor/scene"

RSpec.describe MimeActor::Scene do
  let(:klazz) { Class.new.include described_class }

  describe "#compose_scene" do
    subject(:act) { klazz.compose_scene(*params) }

    let(:params) { Array.wrap(formats) + [actions] }
    let(:formats) { :xml }
    let(:actions) { { on: :index } }

    context "with unsupported format" do
      let(:formats) { %i[html my_custom_type json] }

      it "raises ArgumentError" do
        expect { act }.to raise_error(ArgumentError, "Unsupported format: my_custom_type")
      end
    end

    context "without action name" do
      let(:actions) { nil }

      it "raises ArgumentError" do
        expect { act }.to raise_error(ArgumentError, "Action name can't be empty, e.g. on: :create")
      end
    end

    describe "when action name is #new" do
      let(:actions) { { on: :new } }

      it "stores config in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.acting_scenes).to include("new" => Set[:xml])
      end

      it "defines the action method" do
        expect(klazz).not_to be_method_defined(:new)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:new)
      end
    end

    context "with single format and single action" do
      let(:formats) { :html }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.acting_scenes).to include("create" => Set[:html])
      end

      it "defines the action method" do
        expect(klazz).not_to be_method_defined(:create)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:create)
      end

      context "with the newly defined aciton method" do
        let(:controller) { klazz.new }

        it "calls cue_actor" do
          expect { act }.not_to raise_error
          allow(controller).to receive(:cue_actor).and_return("test")
          expect(controller.create).to eq "test"
          expect(controller).to have_received(:cue_actor).with(:play_scene, :create)
        end
      end
    end

    context "with multiple formats and single action" do
      let(:formats) { %i[html json] }
      let(:actions) { { on: :create } }

      it "stores config in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.acting_scenes).to include("create" => Set[:html, :json])
      end

      it "defines the action method" do
        expect(klazz).not_to be_method_defined(:create)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:create)
      end
    end

    context "with single format and multiple actions" do
      let(:formats) { :html }
      let(:actions) { { on: %i[index create] } }

      it "stores config in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.acting_scenes).to include({
          "index"  => Set[:html],
          "create" => Set[:html]
        })
      end

      it "defines the action methods" do
        expect(klazz).not_to be_method_defined(:create)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:create)
      end
    end

    context "with multiple formats and multiple actions" do
      let(:formats) { %i[html json xml] }
      let(:actions) { { on: %i[index create update] } }

      it "stores config in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        expect { act }.not_to raise_error
        expect(klazz.acting_scenes).to include({
          "index"  => Set[:html, :json, :xml],
          "create" => Set[:html, :json, :xml],
          "update" => Set[:html, :json, :xml]
        })
      end

      it "defines the action methods" do
        expect(klazz).not_to be_method_defined(:index)
        expect(klazz).not_to be_method_defined(:create)
        expect(klazz).not_to be_method_defined(:update)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:index)
        expect(klazz).to be_method_defined(:create)
        expect(klazz).to be_method_defined(:update)
      end
    end

    context "with multiple times calls" do
      it "merges mappings in class attributes" do
        expect(klazz.acting_scenes).to be_empty
        klazz.compose_scene(:html, on: %i[index create])
        expect(klazz.acting_scenes).to include({
          "index"  => Set[:html],
          "create" => Set[:html]
        })
        klazz.compose_scene(:xml, on: %i[create update])
        expect(klazz.acting_scenes).to include({
          "index"  => Set[:html],
          "create" => Set[:html, :xml],
          "update" => Set[:xml]
        })
        klazz.compose_scene(:json, :xml, on: %i[create show])
        expect(klazz.acting_scenes).to include({
          "index"  => Set[:html],
          "create" => Set[:html, :xml, :json],
          "update" => Set[:xml],
          "show"   => Set[:json, :xml]
        })
      end
    end

    describe "when action method is not defined" do
      let(:klazz_instance) { klazz.new }
      let(:formats) { :xml }
      let(:actions) { { on: :create } }

      it "defines the action method" do
        expect(klazz).not_to be_method_defined(:create)
        expect(klazz.singleton_class).not_to be_method_defined(:create)
        expect { act }.not_to raise_error
        expect(klazz).to be_method_defined(:create)
        expect(klazz.singleton_class).not_to be_method_defined(:create)
      end

      context "with #play_scene defined" do
        before do
          klazz.define_method(:play_scene) { |a| "play a scene with #{a}" }
        end

        it "calls the method" do
          expect { act }.not_to raise_error
          allow(klazz_instance).to receive(:play_scene).and_call_original
          expect(klazz_instance.create).to eq "play a scene with create"
          expect(klazz_instance).to have_received(:play_scene)
        end
      end

      context "with #play_scene undefined" do
        it "does not call the method" do
          expect { act }.not_to raise_error
          expect(klazz_instance.create).to be_falsey
        end
      end
    end

    describe "when action method already defined" do
      let(:formats) { :xml }
      let(:actions) { { on: :create } }

      before do
        klazz.singleton_class.define_method(:action_methods) { ["create"] }
      end

      it "raises ArgumentError" do
        expect { act }.to raise_error(ArgumentError, "Action method already defined: create")
      end
    end
  end
end
