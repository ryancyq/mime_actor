# frozen_string_literal: true

require "mime_actor/logging"
require "logger"

RSpec.describe MimeActor::Logging do
  let(:klazz) { Class.new.include described_class }
  let(:klazz_instance) { klazz.new }
  let(:stub_logger_class) { Class.new(Logger) }

  describe "#logger" do
    it "returns default logger" do
      expect(klazz.logger).to be_present
      expect(klazz.logger).to be_a(ActiveSupport::TaggedLogging)
    end

    it "allows reassignment" do
      expect(klazz.logger).to be_present
      klazz.logger = stub_logger_class.new($stdout)
      expect(klazz.logger).to be_a(stub_logger_class)
    end
  end

  describe "#config" do
    it "allows configure" do
      expect(klazz.logger).not_to be_a(stub_logger_class)
      expect do
        klazz.configure do |config|
          config.logger = stub_logger_class.new($stdout)
        end
      end.not_to raise_error
      expect(klazz.logger).to be_a(stub_logger_class)
    end
  end

  describe "#fill_run_sheet" do
    let(:log_formatter) { klazz.logger.formatter }

    it "include default tag \"MimeActor\"" do
      expect(log_formatter.current_tags).not_to include("MimeActor")
      klazz_instance.send(:fill_run_sheet) do
        expect(log_formatter.current_tags).to include("MimeActor")
      end
      expect(log_formatter.current_tags).not_to include("MimeActor")
    end

    it "allows tagging" do
      expect(log_formatter.current_tags).not_to include("my_tag_a")
      klazz_instance.send(:fill_run_sheet, "my_tag_a", "my_tag_b") do
        expect(log_formatter.current_tags).to include("my_tag_a")
        expect(log_formatter.current_tags).to include("my_tag_b")
      end
      expect(log_formatter.current_tags).not_to include("my_tag")
    end
  end
end
