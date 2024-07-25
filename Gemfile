# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "actionpack", ">= 5.0"
gem "activesupport", ">= 5.0"
gem "rake", ">= 11.0"

group :development, :test do
  gem "rails", ">= 5.0"
  gem "rspec", "~> 3.12"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-cobertura", require: false
end

group :development do
  gem "rubocop", "~> 1.65", require: false
  gem "rubocop-rake", require: false
  gem "rubocop-rspec", require: false
end
