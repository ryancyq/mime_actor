# frozen_string_literal: true

RSpec.shared_examples "runnable act callbacks action filter" do |kind, filter, acceptance: true|
  let(:klazz) { Class.new.include described_class }
  let(:kind_act) { :"act_#{kind}" }
  let(:kind_callback) { :"my_#{kind}" }
  let(:action_filter) { nil }
  let(:run) { klazz.public_send(kind_act, kind_callback, action: action_filter) }

  if acceptance
    it "accepts #{filter || "action"} filter" do
      expect { run }.not_to raise_error
    end
  else
    it "rejects #{filter || "action"} filter" do
      expect { run }.to raise_error(error_class_raised, error_message_raised)
    end
  end
end

RSpec.shared_examples "runnable act callbacks format filter" do |kind, filter, acceptance: true|
  let(:klazz) { Class.new.include described_class }
  let(:kind_act) { :"act_#{kind}" }
  let(:kind_callback) { :"my_#{kind}" }
  let(:format_filter) { nil }
  let(:run) { klazz.public_send(kind_act, kind_callback, format: format_filter) }

  if acceptance
    it "accepts #{filter || "format"} filter" do
      expect { run }.not_to raise_error
    end
  else
    it "rejects #{filter || "format"} filter" do
      expect { run }.to raise_error(error_class_raised, error_message_raised)
    end
  end
end

RSpec.shared_examples "runnable act callbacks" do |kind|
  include_context "with act callbacks"

  describe ":#{kind}" do
    let(:kind_act) { :"act_#{kind}" }
    let(:kind_callback) { :"my_#{kind}" }

    before do
      klazz.public_send kind_act, kind_callback
      klazz.define_method(kind_callback) { "something" }
      allow(klazz_instance).to receive(kind_callback).and_yield if kind == :around
    end

    it "runs :#{kind} callback" do
      allow(klazz_instance).to receive(kind_callback)
      expect { run }.not_to raise_error
      expect(klazz_instance).to have_received(kind_callback)
    end

    context "with action filter" do
      let(:act_action) { :create }
      let(:action_filter) { :create }
      let(:kind_action_callback) { :"my_#{kind}_action" }

      before do
        klazz.public_send kind_act, kind_action_callback, action: action_filter
        klazz.define_method(kind_action_callback) { "something" }
        allow(klazz_instance).to receive(kind_action_callback).and_yield if kind == :around
      end

      it "runs :#{kind} callback with action filter" do
        allow(klazz_instance).to receive(kind_action_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_action_callback)
      end

      it "runs :#{kind} callback without action filter" do
        allow(klazz_instance).to receive(kind_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_callback)
      end

      context "when action filter not matched" do
        let(:act_action) { :show }

        it "does not run :#{kind} callback with action filter" do
          allow(klazz_instance).to receive(kind_action_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(kind_action_callback)
        end

        it "runs :#{kind} callback without action filter" do
          allow(klazz_instance).to receive(kind_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(kind_callback)
        end
      end
    end

    context "with format filter" do
      let(:act_format) { :html }
      let(:format_filter) { :html }
      let(:kind_format_callback) { :"my_#{kind}_format" }

      before do
        klazz.public_send kind_act, kind_format_callback, format: format_filter
        klazz.define_method(kind_format_callback) { "something" }
        allow(klazz_instance).to receive(kind_format_callback).and_yield if kind == :around
      end

      it "run :#{kind} callback with format filter" do
        allow(klazz_instance).to receive(kind_format_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_format_callback)
      end

      it "runs :#{kind} callback without format filter" do
        allow(klazz_instance).to receive(kind_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_callback)
      end

      context "when format filter not matched" do
        let(:act_format) { :json }

        it "does not run :#{kind} callback with format filter" do
          allow(klazz_instance).to receive(kind_format_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(kind_format_callback)
        end

        it "runs :#{kind} callback without format filter" do
          allow(klazz_instance).to receive(kind_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(kind_callback)
        end
      end
    end

    context "with action & format filter" do
      let(:act_action) { :create }
      let(:act_format) { :html }
      let(:action_filter) { :create }
      let(:format_filter) { :html }
      let(:kind_action_format_callback) { :"my_#{kind}_acton_format" }

      before do
        klazz.public_send kind_act, kind_action_format_callback, action: action_filter, format: format_filter
        klazz.define_method(kind_action_format_callback) { "something" }
        allow(klazz_instance).to receive(kind_action_format_callback).and_yield if kind == :around
      end

      it "run :#{kind} callback with action & format filters" do
        allow(klazz_instance).to receive(kind_action_format_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_action_format_callback)
      end

      it "runs :#{kind} callback without action/format filter" do
        allow(klazz_instance).to receive(kind_callback)
        expect { run }.not_to raise_error
        expect(klazz_instance).to have_received(kind_callback)
      end

      context "when action filter not matched" do
        let(:act_action) { :index }

        it "does not run :#{kind} callback with action & format filters" do
          allow(klazz_instance).to receive(kind_action_format_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(kind_action_format_callback)
        end

        it "runs :#{kind} callback without action/format filter" do
          allow(klazz_instance).to receive(kind_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(kind_callback)
        end
      end

      context "when format filter not matched" do
        let(:act_format) { :json }

        it "does not run :#{kind} callback with action & format filters" do
          allow(klazz_instance).to receive(kind_action_format_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).not_to have_received(kind_action_format_callback)
        end

        it "runs :#{kind} callback without action/format filter" do
          allow(klazz_instance).to receive(kind_callback)
          expect { run }.not_to raise_error
          expect(klazz_instance).to have_received(kind_callback)
        end
      end
    end
  end
end
