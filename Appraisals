# frozen_string_literal: true

[
  "6.1.0",
  "7.0.0",
  "7.1.0",
  "7.2.0",
  "8.0.0"
].each do |rails_version|
  appraise "rails-#{rails_version.chomp ".0"}" do
    gem "actionpack", "~> #{rails_version}"
    gem "activesupport", "~> #{rails_version}"
    # json >= 3 drops quirks_mode, still passed by ActiveSupport::JSON before rails 8.1
    gem "json", "< 3"

    group :development, :test do
      gem "rails", "~> #{rails_version}"
    end
  end
end

appraise "rails-edge" do
  gem "actionpack", github: "rails/rails", branch: "main"
  gem "activesupport", github: "rails/rails", branch: "main"

  group :development, :test do
    gem "rails", github: "rails/rails", branch: "main"
  end
end
