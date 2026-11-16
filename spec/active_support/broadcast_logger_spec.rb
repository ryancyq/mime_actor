# frozen_string_literal: true

require "active_support"
require "active_support/logger"
require "active_support/tagged_logging"

RSpec.describe "ActiveSupport::BroadcastLogger", if: defined?(ActiveSupport::BroadcastLogger) do
  let(:outputs) { [StringIO.new, StringIO.new] }
  let(:logger) do
    loggers = outputs.map { |io| ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(io)) }
    ActiveSupport::BroadcastLogger.new(*loggers)
  end

  it "yields #tagged once per logger",
     if: ActiveSupport.version >= Gem::Version.new("7.1") && ActiveSupport.version < Gem::Version.new("8.2.alpha") do
    expect { |block| logger.tagged("create", "html", &block) }.to yield_control.twice
  end

  it "yields #tagged once", if: ActiveSupport.version >= Gem::Version.new("8.2.alpha") do
    expect { |block| logger.tagged("create", "html", &block) }.to yield_control.once
  end

  it "tags every logger with #push_tags and #pop_tags" do
    logger.push_tags("create", "html")
    logger.info("acting")
    logger.pop_tags(2)
    logger.info("after")

    expect(outputs.map(&:string)).to all(eq "[create] [html] acting\nafter\n")
  end
end
