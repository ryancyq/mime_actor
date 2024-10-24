# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "actionpack", "~> 7.2", ">= 7.2.1.1"
gem "activesupport", "~> 7.2", ">= 7.2.1.1"

group :development, :test do
  gem "rails", "~> 7.2", ">= 7.2.1.1"
  gem "rake", ">= 11.0"
  gem "rspec", "~> 3.12"
  gem "rspec-activesupport", "~> 0.1"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-cobertura", require: false
  gem "webrick", ">= 1.8.2"
end

group :development do
  gem "rubocop", ">= 1.28.2", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false

  gem "appraisal", "~> 2.5.0", require: false
end
