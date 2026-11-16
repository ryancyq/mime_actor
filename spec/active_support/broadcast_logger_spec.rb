# frozen_string_literal: true

require "active_support"
require "active_support/logger"
require "active_support/tagged_logging"

# Guards the Rails behaviour behind the README recipe for log tags.
# When "yields #tagged once per logger" fails, Rails has fixed it and the README note can go.
RSpec.describe "ActiveSupport::BroadcastLogger", if: defined?(ActiveSupport::BroadcastLogger) do
  let(:outputs) { [StringIO.new, StringIO.new] }
  let(:logger) do
    loggers = outputs.map { |io| ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(io)) }
    ActiveSupport::BroadcastLogger.new(*loggers)
  end

  it "yields #tagged once per logger" do
    runs = 0
    logger.tagged("create", "html") { runs += 1 }

    expect(runs).to eq 2
  end

  it "tags every logger with #push_tags and #pop_tags" do
    logger.push_tags("create", "html")
    logger.info("acting")
    logger.pop_tags(2)
    logger.info("after")

    expect(outputs.map(&:string)).to all(eq "[create] [html] acting\nafter\n")
  end
end
