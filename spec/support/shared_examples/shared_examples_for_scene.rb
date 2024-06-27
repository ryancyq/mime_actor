# frozen_string_literal: true

require "active_support/core_ext/array/wrap"

RSpec.shared_examples "composable scene action accepted" do |action_name|
  include_context "with scene composition"

  it "accepts #{action_name || "the action"}" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.not_to raise_error
    expect(klazz.acting_scenes).not_to be_empty
    expect(klazz.acting_scenes.keys).to match_array(action_filters)
  end
end

RSpec.shared_examples "composable scene action rejected" do |action_name|
  include_context "with scene composition"

  let(:error_class_raised) { MimeActor::ActionFilterInvalid }
  let(:error_message_raised) { "Action filter must be Symbol" }

  it "rejects #{action_name || "the action"}" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.to raise_error(error_class_raised, error_message_raised)
    expect(klazz.acting_scenes.keys).not_to include([])
  end
end

RSpec.shared_examples "composable scene format accepted" do |format_name|
  include_context "with scene composition"

  it "accepts #{format_name || "the format"}" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.not_to raise_error
    expect(klazz.acting_scenes).not_to be_empty
    expect(klazz.acting_scenes.values.reduce(:|)).to match_array(format_filters)
  end
end

RSpec.shared_examples "composable scene format rejected" do |format_name|
  include_context "with scene composition"

  let(:error_class_raised) { MimeActor::FormatInvalid }
  let(:error_message_raised) { /Invalid format:/ }

  it "rejects #{format_name || "the format"}" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.to raise_error(error_class_raised, error_message_raised)
  end
end

RSpec.shared_examples "composable scene action method" do |scene_name|
  include_context "with scene composition"

  let(:expected_scenes) do
    action_filters.each_with_object({}) do |action_name, result|
      action_name = action_name.to_sym
      result[action_name] ||= Set.new

      format_filters.each do |format_name|
        result[action_name] |= [format_name.to_sym]
      end
    end
  end

  it "stores #{scene_name || "the scene"} config" do
    expect(klazz.acting_scenes).to be_empty
    expect { compose }.not_to raise_error
    expect(expected_scenes.size).to eq action_filters.size
    expect(klazz.acting_scenes).to eq expected_scenes
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
        MimeActor::ActionExisted, "Action :#{expected_scenes.keys.first} already existed"
      )
    end
  end

  describe "when #play_scene is defined for #{scene_name || "the scene"}" do
    let(:klazz_instance) { klazz.new }

    before { klazz.define_method(:play_scene) { |action_name| "play a scene with #{action_name}" } }

    it "called by the newly defined action method" do
      expect { compose }.not_to raise_error
      allow(klazz_instance).to receive(:play_scene).and_call_original
      expected_scenes.each_key do |action_name|
        expect(klazz_instance.send(action_name)).to eq "play a scene with #{action_name}"
        expect(klazz_instance).to have_received(:play_scene).with(action_name)
      end
    end
  end

  describe "when #play_scene is undefined for #{scene_name || "the scene"}" do
    let(:klazz_instance) { klazz.new }

    it "does not get called by the newly defined action method" do
      expect { compose }.not_to raise_error
      expect(klazz).not_to be_method_defined(:play_scene)
      expected_scenes.each_key do |action_name|
        expect(klazz_instance.send(action_name)).to be_falsey
      end
    end
  end
end
