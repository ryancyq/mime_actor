# frozen_string_literal: true

RSpec.shared_examples "composable scene action" do |action_name, acceptance: true|
  include_context "with scene composition"

  if acceptance
    it "accepts #{action_name || "the action"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.not_to raise_error
      expect(klazz.acting_scenes).not_to be_empty
      expect(klazz.acting_scenes.keys).to match_array(action_filters)
    end
  else
    let(:error_class_raised) { ArgumentError }
    let(:error_message_raised) { "action must be a Symbol" }

    it "rejects #{action_name || "the action"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.acting_scenes.keys).not_to include([])
    end
  end
end

RSpec.shared_examples "composable scene format" do |format_name, acceptance: true|
  include_context "with scene composition"

  if acceptance
    it "accepts #{format_name || "the format"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.not_to raise_error
      expect(klazz.acting_scenes).not_to be_empty
      expect(klazz.acting_scenes.values.flat_map(&:keys)).to match_array(format_filters)
    end
  else
    let(:error_class_raised) { NameError }
    let(:error_message_raised) { /invalid formats, got:/ }

    it "rejects #{format_name || "the format"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.acting_scenes).to be_empty
    end
  end
end

RSpec.shared_examples "composable scene with handler" do |handler_name, handler_type, acceptance: true|
  include_context "with scene composition"

  let(:compose) { klazz.respond_act_to(*format_filters, on: action_params, with: handler) }
  let(:expected_scenes) do
    action_filters.each_with_object({}) do |action_name, result|
      action_name = action_name.to_sym
      result[action_name] ||= {}

      format_filters.each do |format_name|
        result[action_name][format_name.to_sym] = kind_of(handler_type)
      end
    end
  end

  if acceptance
    it "accepts #{handler_name || "the handler"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.not_to raise_error
      expect(klazz.acting_scenes).not_to be_empty
      expect(klazz.acting_scenes).to include expected_scenes
    end
  else
    let(:error_class_raised) { ArgumentError }
    let(:error_message_raised) { /with handler must be a Symbol or Proc, got:/ }

    it "rejects #{handler_name || "the handler"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.acting_scenes).to be_empty
    end
  end
end

RSpec.shared_examples "composable scene action method" do |scene_name|
  include_context "with scene composition"

  let(:expected_scenes) do
    action_filters.each_with_object({}) do |action_name, result|
      action_name = action_name.to_sym
      result[action_name] ||= {}

      format_filters.each do |format_name|
        result[action_name][format_name.to_sym] = anything
      end
    end
  end

  it "stores #{scene_name || "the scene"} config" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.not_to raise_error
    expect(expected_scenes.size).to eq action_filters.size
    expect(klazz.acting_scenes).to include expected_scenes
  end

  describe "when action method is undefined for #{scene_name || "the scene"}" do
    it "defines the action method" do
      expected_scenes.each_key do |action_name|
        expect(klazz).not_to be_method_defined(action_name)
        expect(klazz.singleton_class).not_to be_method_defined(action_name)
      end
      expect { compose }.not_to raise_error
      expected_scenes.each_key do |action_name|
        expect(klazz).to be_method_defined(action_name)
        expect(klazz.singleton_class).not_to be_method_defined(action_name)
      end
    end
  end

  describe "when action method has already defined for #{scene_name || "the scene"}" do
    before do
      expected_scenes.each_key do |action_name|
        klazz.define_method(action_name) { "stub #{action_name}" }
      end
    end

    it "raises #{MimeActor::ActionExisted}" do
      expect { compose }.to raise_error(
        MimeActor::ActionExisted, "action :#{expected_scenes.keys.first} already existed"
      )
    end
  end

  describe "when #start_scene is defined for #{scene_name || "the scene"}" do
    let(:klazz_instance) { klazz.new }

    before { klazz.define_method(:start_scene) { |action_name| "start a scene with #{action_name}" } }

    it "called by the newly defined action method" do
      expect { compose }.not_to raise_error
      allow(klazz_instance).to receive(:start_scene).and_call_original
      expected_scenes.each_key do |action_name|
        expect(klazz_instance.send(action_name)).to eq "start a scene with #{action_name}"
        expect(klazz_instance).to have_received(:start_scene).with(action_name)
      end
    end
  end

  describe "when #start_scene is undefined for #{scene_name || "the scene"}" do
    let(:klazz_instance) { klazz.new }

    it "does not get called by the newly defined action method" do
      expect(klazz).not_to be_method_defined(:start_scene)
      expect { compose }.not_to raise_error
      expected_scenes.each_key do |action_name|
        expect(klazz_instance.send(action_name)).to be_falsey
      end
    end
  end
end
