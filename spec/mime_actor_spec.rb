# frozen_string_literal: true

require "action_controller"
require "mime_actor"

RSpec.describe MimeActor do
  let(:klazz) { Class.new.include described_class }

  describe "#action_formatters" do
    it "is empty by default" do
      expect(klazz.action_formatters).to be_empty
    end

    it "allows instance reader" do
      expect(klazz.new.action_formatters).to be_empty
    end

    it "disallows instance writter" do
      expect { klazz.new.action_formatters = {} }.to raise_error(
        NoMethodError, /undefined method `action_formatters='/
      )
    end
  end

  describe "#raise_on_missing_action_formatter" do
    it "is false by default" do
      expect(klazz.raise_on_missing_action_formatter).to be_falsey
    end

    it "allows instance reader" do
      expect(klazz.new.raise_on_missing_action_formatter).to be_falsey
    end
    
    it "disallows instance writter" do
      expect { klazz.new.raise_on_missing_action_formatter = true }.to raise_error(
        NoMethodError, /undefined method `raise_on_missing_action_formatter='/
      )
    end
  end

  describe "#act_on_format" do
    it "exists" do
      expect { klazz.act_on_format }.to raise_error(ArgumentError)
    end
  end
end