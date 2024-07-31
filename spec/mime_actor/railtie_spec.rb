# frozen_string_literal: true

require "mime_actor"
require "active_support/deprecation"
require "active_support/logger"

RSpec.describe MimeActor::Railtie do
  let(:app) { Class.new(Rails::Application) }

  before do
    app.config.eager_load = false
    app.config.logger = ActiveSupport::Logger.new(nil)
    app.config.load_defaults Rails.gem_version.segments.take(2).join(".")
    app.initialize!
  end

  it "adds deprecator" do
    skip "only for Rails >= 7.0" if Rails::VERSION::MAJOR < 7
    expect(app.deprecators[:mime_actor]).to be_a(ActiveSupport::Deprecation)
  end
end
