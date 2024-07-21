# frozen_string_literal: true

require "mime_actor/callbacks"

RSpec.describe MimeActor::Callbacks do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:run_format) { :html }
  let(:run) { klazz_instance.run_act_callbacks(run_format) }

  describe "before" do
    before do
      klazz.before_act :my_before
      klazz.define_method(:my_before) { "something" }
    end

    it "runs the callback" do
      allow(klazz_instance).to receive(:my_before)
      expect { run }.not_to raise_error
      expect(klazz_instance).to have_received(:my_before)
    end

    context "with action filter" do
      before do
        klazz.define_method(:action_name) { "create" }
        klazz.before_act :my_before_action, action: :create
        klazz.define_method(:my_before_action) { "something" }
      end

      it "runs the callback" do
        allow(klazz_instance).to receive(:my_before_action)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before_action)
      end

      it "runs the callback without action filter" do
        allow(klazz_instance).to receive(:my_before)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before)
      end

      context "when action filter not matched" do
        before { klazz.define_method(:action_name) { "show" } }

        it "does not run the callback" do
          allow(klazz_instance).to receive(:my_before_action)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(:my_before_action)
        end

        it "runs the callback without action filter" do
          allow(klazz_instance).to receive(:my_before)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(:my_before)
        end
      end
    end

    context "with format filter" do
      let(:run_format) { :html }

      before do
        klazz.before_act :my_before_format, format: :html
        klazz.define_method(:my_before_format) { "something" }
      end

      it "run the callback" do
        allow(klazz_instance).to receive(:my_before_format)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before_format)
      end

      it "runs the callback without format filter" do
        allow(klazz_instance).to receive(:my_before)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before)
      end

      context "when format filter not matched" do
        let(:run_format) { :json }

        it "does not run the callback" do
          allow(klazz_instance).to receive(:my_before_format)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(:my_before_format)
        end

        it "runs the callback without format filter" do
          allow(klazz_instance).to receive(:my_before)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(:my_before)
        end
      end
    end

    context "with action & format filter" do
      let(:run_format) { :html }

      before do
        klazz.define_method(:action_name) { "create" }
        klazz.before_act :my_before_action_format, action: :create, format: :html
        klazz.define_method(:my_before_action_format) { "something" }
      end

      it "run the callback" do
        allow(klazz_instance).to receive(:my_before_action_format)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before_action_format)
      end

      it "runs the callback without action/format filter" do
        allow(klazz_instance).to receive(:my_before)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(:my_before)
      end

      context "when action filter not matched" do
        before { klazz.define_method(:action_name) { "index" } }

        it "does not run the callback" do
          allow(klazz_instance).to receive(:my_before_action_format)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(:my_before_action_format)
        end

        it "runs the callback without format filter" do
          allow(klazz_instance).to receive(:my_before)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(:my_before)
        end
      end

      context "when format filter not matched" do
        let(:run_format) { :json }

        it "does not run the callback" do
          allow(klazz_instance).to receive(:my_before_action_format)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(:my_before_action_format)
        end

        it "runs the callback without format filter" do
          allow(klazz_instance).to receive(:my_before)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(:my_before)
        end
      end
    end
  end
end
