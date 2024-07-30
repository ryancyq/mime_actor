# frozen_string_literal: true

RSpec.shared_examples "composable scene action" do |action_name, acceptance: true|
  include_context "with scene composition"

  if acceptance
    it "accepts #{action_name || "the action"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.not_to raise_error
      expect(klazz.acting_scenes).not_to be_empty
      expect(klazz.acting_scenes.keys).to match_array(Array(action_filter))
    end
  else
    it "rejects #{action_name || "the action"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.acting_scenes).to be_empty
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
      expect(klazz.acting_scenes.values.flat_map(&:keys)).to match_array(Array(format_filter))
    end
  else
    it "rejects #{format_name || "the format"}" do
      expect(klazz.acting_scenes).to be_empty
      expect { compose }.to raise_error(error_class_raised, error_message_raised)
      expect(klazz.acting_scenes).to be_empty
    end
  end
end

RSpec.shared_examples "composable scene with handler" do |handler_name, handler_type, acceptance: true|
  include_context "with scene composition"

  let(:compose) do
    if format_filter.is_a?(Enumerable)
      klazz.act_on_action(*action_filter, format: format_filter, with: handler)
    else
      klazz.act_on_action(action_filter, format: format_filter, with: handler)
    end
  end
  let(:expected_scenes) do
    Array(action_filter).each_with_object({}) do |action_name, result|
      action_name = action_name.to_sym
      result[action_name] ||= {}

      Array(format_filter).each do |format_name|
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
    Array(action_filter).each_with_object({}) do |action_name, result|
      action_name = action_name.to_sym
      result[action_name] ||= {}

      Array(format_filter).each do |format_name|
        result[action_name][format_name.to_sym] = anything
      end
    end
  end

  it "stores #{scene_name || "the scene"} config" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.not_to raise_error
    expect(expected_scenes.size).to eq Array(action_filter).size
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

    before { klazz.define_method(:start_scene) { "start a scene" } }

    it "called by the newly defined action method" do
      expect { compose }.not_to raise_error
      allow(klazz_instance).to receive(:start_scene).and_call_original
      expected_scenes.each_key do |action_name|
        expect(klazz_instance.send(action_name)).to eq "start a scene"
      end
      expect(klazz_instance).to have_received(:start_scene).exactly(expected_scenes.size)
    end
  end
end
