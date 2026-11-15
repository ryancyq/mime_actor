# frozen_string_literal: true

[
  "6.1.0",
  "7.0.0",
  "7.1.0",
  "7.2.0",
  "8.0.0",
  "8.1.0"
].each do |rails_version|
  appraise "rails-#{rails_version.chomp ".0"}" do
    gem "actionpack", "~> #{rails_version}"
    gem "activesupport", "~> #{rails_version}"
    # json >= 3 drops quirks_mode, still passed by ActiveSupport::JSON on these rails
    # not on 7.2: ruby >= 4.1 ships json 3 as default gem, the pin conflicts with it
    gem "json", "< 3" if %w[6.1.0 7.0.0 7.1.0 8.0.0].include?(rails_version)

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
