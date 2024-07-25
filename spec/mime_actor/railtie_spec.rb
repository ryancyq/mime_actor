# frozen_string_literal: true

require "mime_actor"
require "active_support/deprecation"
require "active_support/logger"

RSpec.describe MimeActor::Railtie do
  let(:app) { Class.new(Rails::Application) }

  before do
    app.config.eager_load = false
    app.config.logger = ActiveSupport::Logger.new($stdout)
    app.config.load_defaults 7.1
    app.initialize!
  end

  it "adds deprecator" do
    expect(app.deprecators[:mime_actor]).to be_a(ActiveSupport::Deprecation)
  end
end
